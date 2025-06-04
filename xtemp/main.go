
package main

import (
    "bytes"
    "crypto/rand"
    "encoding/base64"
    "errors"
    "fmt"
    "io"
    "log"
    "net"
    "net/http"
    "net/url"
    "os"
    "path/filepath"
    "strconv"
    "strings"
    "time"

    "github.com/aws/aws-sdk-go/aws"
    "github.com/aws/aws-sdk-go/aws/credentials"
    "github.com/aws/aws-sdk-go/aws/session"
    "github.com/aws/aws-sdk-go/service/s3"
    "github.com/gin-gonic/gin"
)

// --- Config and Constants ---

const (
    envBaseStoragePath = "XTEMP_STORAGE_PATH"
    envTrustedProxies  = "TRUSTED_PROXIES"
    envMaxUploadSize   = "MAX_UPLOAD_SIZE"
    envStorageType     = "STORAGE_TYPE"
    envR2AccountID     = "R2_ACCOUNT_ID"
    envR2AccessKeyID   = "R2_ACCESS_KEY_ID"
    envR2SecretAccessKey = "R2_SECRET_ACCESS_KEY"
    envR2BucketName    = "R2_BUCKET_NAME"

    defaultStoragePath   = "/var/lib/xtemp-store"
    defaultMaxUploadSize = 50 << 20 // 50MB
    bufferSize           = 16 * 1024

    dirPerm  os.FileMode = 0750
    filePerm os.FileMode = 0640
)

type StorageType string

const (
    StorageLocal StorageType = "local"
    StorageR2    StorageType = "r2"
)

type AppConfig struct {
    BaseStoragePath   string
    MaxUploadSize     int64
    TrustedProxies    []string
    StorageType       StorageType
    R2AccountID       string
    R2AccessKeyID     string
    R2SecretAccessKey string
    R2BucketName      string
}

// --- Globals ---

var (
    logger   *log.Logger
    config   *AppConfig
    s3Client *s3.S3
    r2Bucket string
)

// --- Initialization ---

func init() {
    logger = log.New(os.Stdout, "xtemp_app: ", log.Ldate|log.Ltime|log.Lshortfile)
    config = loadConfig()

    switch config.StorageType {
    case StorageLocal:
        if err := os.MkdirAll(config.BaseStoragePath, dirPerm); err != nil {
            logger.Fatalf("Could not create base storage directory %s: %v", config.BaseStoragePath, err)
        }
        logger.Printf("Base storage directory %s ensured with permissions %o", config.BaseStoragePath, dirPerm)
    case StorageR2:
        endpoint := fmt.Sprintf("https://%s.r2.cloudflarestorage.com", config.R2AccountID)
        sess, err := session.NewSession(&aws.Config{
            Region:           aws.String("auto"),
            Endpoint:         aws.String(endpoint),
            S3ForcePathStyle: aws.Bool(true),
            Credentials:      credentials.NewStaticCredentials(config.R2AccessKeyID, config.R2SecretAccessKey, ""),
        })
        if err != nil {
            logger.Fatalf("Failed to create R2 session: %v", err)
        }
        s3Client = s3.New(sess)
        r2Bucket = config.R2BucketName
        logger.Printf("R2 client initialized for endpoint %s, bucket %s", endpoint, r2Bucket)
    }

    logger.Printf("Max upload size set to %d bytes (%dMB)", config.MaxUploadSize, config.MaxUploadSize/(1<<20))
    logger.Printf("Trusted proxies configured: %v", config.TrustedProxies)
    logger.Printf("Storage type: %s", config.StorageType)
}

func loadConfig() *AppConfig {
    cfg := &AppConfig{
        BaseStoragePath: defaultStoragePath,
        MaxUploadSize:   defaultMaxUploadSize,
        TrustedProxies: []string{"127.0.0.1", "::1", "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "fc00::/7"},
        StorageType:     StorageLocal,
    }
    if path := os.Getenv(envBaseStoragePath); path != "" {
        cfg.BaseStoragePath = filepath.Clean(path)
    }
    if sizeStr := os.Getenv(envMaxUploadSize); sizeStr != "" {
        size, err := strconv.ParseInt(sizeStr, 10, 64)
        if err == nil && size > 0 {
            cfg.MaxUploadSize = size
        } else {
            logger.Printf("Invalid %s value '%s', using default %dMB", envMaxUploadSize, sizeStr, defaultMaxUploadSize/(1<<20))
        }
    }
    if proxyStr := os.Getenv(envTrustedProxies); proxyStr != "" {
        proxies := strings.Split(proxyStr, ",")
        validProxies := make([]string, 0, len(proxies))
        for _, p := range proxies {
            trimmed := strings.TrimSpace(p)
            if _, _, err := net.ParseCIDR(trimmed); err == nil {
                validProxies = append(validProxies, trimmed)
            } else if ip := net.ParseIP(trimmed); ip != nil {
                validProxies = append(validProxies, trimmed)
            } else if trimmed != "" {
                logger.Printf("Invalid proxy format in TRUSTED_PROXIES: %s", trimmed)
            }
        }
        if len(validProxies) > 0 {
            cfg.TrustedProxies = validProxies
        } else {
            logger.Println("No valid proxies found in TRUSTED_PROXIES, using default.")
        }
    }
    if st := os.Getenv(envStorageType); st != "" {
        st = strings.ToLower(strings.TrimSpace(st))
        if st == string(StorageLocal) || st == string(StorageR2) {
            cfg.StorageType = StorageType(st)
        } else {
            logger.Printf("Invalid STORAGE_TYPE '%s', using default 'local'", st)
        }
    }
    cfg.R2AccountID = os.Getenv(envR2AccountID)
    cfg.R2AccessKeyID = os.Getenv(envR2AccessKeyID)
    cfg.R2SecretAccessKey = os.Getenv(envR2SecretAccessKey)
    cfg.R2BucketName = os.Getenv(envR2BucketName)
    return cfg
}

// --- Utility Functions ---

func abortWithError(c *gin.Context, statusCode int, message string, err error) {
    fullMessage := message
    if err != nil {
        fullMessage = fmt.Sprintf("%s: %v", message, err)
    }
    logger.Printf("Client Error: %s (IP: %s, Request: %s %s)", fullMessage, c.ClientIP(), c.Request.Method, c.Request.URL.Path)
    c.JSON(statusCode, gin.H{"error": message})
    c.Abort()
}

func generateUniqueID() string {
    b := make([]byte, 12)
    _, err := rand.Read(b)
    if err != nil {
        logger.Printf("CRITICAL: crypto/rand.Read failed: %v. Using pseudo-random fallback.", err)
        return fmt.Sprintf("%d", time.Now().UnixNano())
    }
    return base64.URLEncoding.EncodeToString(b)
}

func getSanitizedUserPath(pathParam string) (string, error) {
    cleaned := strings.Trim(pathParam, "/ ")
    if cleaned == "" {
        return "", errors.New("filepath cannot be empty")
    }
    if len(cleaned) > 255 {
        return "", errors.New("filepath segment is too long")
    }
    if strings.Contains(cleaned, "..") {
        return "", errors.New("invalid characters in filepath (path traversal attempt)")
    }
    if filepath.IsAbs(cleaned) {
        return "", errors.New("filepath must be relative")
    }
    return filepath.Clean(cleaned), nil
}

func buildAndVerifyStoragePath(randomID, userFilePath string) (fullPath string, targetDir string, err error) {
    targetDir = filepath.Join(config.BaseStoragePath, randomID)
    fullPath = filepath.Join(targetDir, userFilePath)
    absBasePath, _ := filepath.Abs(config.BaseStoragePath)
    absFullPath, _ := filepath.Abs(fullPath)
    if !strings.HasPrefix(absFullPath, absBasePath) {
        return "", "", errors.New("invalid filepath, attempts to escape base storage directory")
    }
    if config.StorageType == StorageLocal {
        dirToCreate := filepath.Dir(fullPath)
        if err := os.MkdirAll(dirToCreate, dirPerm); err != nil {
            return "", "", fmt.Errorf("failed to create directory %s: %w", dirToCreate, err)
        }
    }
    return fullPath, targetDir, nil
}

func saveFileContent(dstPath string, src io.Reader) (int64, error) {
    if config.StorageType == StorageR2 {
        return saveFileContentR2(dstPath, src)
    }
    file, err := os.OpenFile(dstPath, os.O_RDWR|os.O_CREATE|os.O_TRUNC, filePerm)
    if err != nil {
        return 0, fmt.Errorf("failed to open file %s for writing: %w", dstPath, err)
    }
    defer file.Close()
    buf := make([]byte, bufferSize)
    written, err := io.CopyBuffer(file, src, buf)
    if err != nil {
        os.Remove(dstPath)
        return 0, fmt.Errorf("failed to write content to file %s: %w", dstPath, err)
    }
    return written, nil
}

func saveFileContentR2(dstPath string, src io.Reader) (int64, error) {
    rel, err := filepath.Rel(config.BaseStoragePath, dstPath)
    if err != nil {
        return 0, fmt.Errorf("failed to get relative path for R2 key: %w", err)
    }
    key := filepath.ToSlash(rel)
    buf := new(bytes.Buffer)
    n, err := io.Copy(buf, src)
    if err != nil {
        return 0, fmt.Errorf("failed to read file content for R2 upload: %w", err)
    }
    upParams := &s3.PutObjectInput{
        Bucket: aws.String(r2Bucket),
        Key:    aws.String(key),
        Body:   bytes.NewReader(buf.Bytes()),
    }
    _, err = s3Client.PutObject(upParams)
    if err != nil {
        return 0, fmt.Errorf("failed to upload to R2: %w", err)
    }
    return n, nil
}

func getBaseURL(r *http.Request) string {
    scheme := "http"
    if r.TLS != nil || r.Header.Get("X-Forwarded-Proto") == "https" {
        scheme = "https"
    }
    host := r.Host
    return fmt.Sprintf("%s://%s", scheme, host)
}

// --- Handlers ---

func commonUploadLogic(c *gin.Context, filename string, bodyReader io.Reader, isPut bool) {
    randomID := generateUniqueID()
    sanitizedFilename, err := getSanitizedUserPath(filename)
    if err != nil {
        abortWithError(c, http.StatusBadRequest, "Invalid filename provided", err)
        return
    }
    fullStoragePath, _, err := buildAndVerifyStoragePath(randomID, sanitizedFilename)
    if err != nil {
        abortWithError(c, http.StatusInternalServerError, "Failed to prepare storage path", err)
        return
    }
    limitedReader := io.LimitedReader{R: bodyReader, N: config.MaxUploadSize + 1}
    bytesWritten, err := saveFileContent(fullStoragePath, &limitedReader)
    if err != nil {
        abortWithError(c, http.StatusInternalServerError, "Failed to save file", err)
        return
    }
    if bytesWritten > config.MaxUploadSize {
        if config.StorageType == StorageLocal {
            os.Remove(fullStoragePath)
        }
        abortWithError(c, http.StatusRequestEntityTooLarge,
            fmt.Sprintf("Uploaded file size (%d bytes) exceeds maximum allowed size (%d bytes)", bytesWritten, config.MaxUploadSize), nil)
        return
    }
    urlEncodedFilename := url.PathEscape(sanitizedFilename)
    accessURL := fmt.Sprintf("%s/%s/%s", getBaseURL(c.Request), randomID, urlEncodedFilename)
    deleteCommand := fmt.Sprintf("curl -X DELETE '%s'", accessURL)
    if config.StorageType == StorageR2 {
        rel, _ := filepath.Rel(config.BaseStoragePath, fullStoragePath)
        key := filepath.ToSlash(rel)
        logger.Printf("File uploaded to R2: key=%s (size %d bytes). Access URL: %s. Delete Command: %s", key, bytesWritten, accessURL, deleteCommand)
    } else {
        logger.Printf("File %s (size %d bytes) uploaded successfully. Access URL: %s. Delete Command: %s", fullStoragePath, bytesWritten, accessURL, deleteCommand)
    }
    c.JSON(http.StatusCreated, gin.H{
        "message":        "File uploaded successfully",
        "id":             randomID,
        "filepath":       sanitizedFilename,
        "url":            accessURL,
        "delete_command": deleteCommand,
        "size":           bytesWritten,
    })
}

func handleUploadPost(c *gin.Context) {
    file, header, err := c.Request.FormFile("file")
    if err != nil {
        abortWithError(c, http.StatusBadRequest, "Failed to get file from form", err)
        return
    }
    defer file.Close()
    originalFilename := header.Filename
    commonUploadLogic(c, originalFilename, file, false)
}

func handleUploadPut(c *gin.Context) {
    userPath := c.Param("filepath")
    if userPath == "" || userPath == "/" {
        abortWithError(c, http.StatusBadRequest, "Filepath for PUT cannot be empty", nil)
        return
    }
    commonUploadLogic(c, userPath, c.Request.Body, true)
}

func handleDownloadFile(c *gin.Context) {
    randomID := c.Param("random_id")
    userFilePath, err := getSanitizedUserPath(c.Param("filepath"))
    if err != nil {
        abortWithError(c, http.StatusBadRequest, "Invalid filepath in URL", err)
        return
    }
    fullStoragePath, _, err := buildAndVerifyStoragePath(randomID, userFilePath)
    if err != nil {
        abortWithError(c, http.StatusInternalServerError, "Error accessing file path", err)
        return
    }
    if config.StorageType == StorageR2 {
        rel, err := filepath.Rel(config.BaseStoragePath, fullStoragePath)
        if err != nil {
            abortWithError(c, http.StatusInternalServerError, "Failed to get R2 key", err)
            return
        }
        key := filepath.ToSlash(rel)
        getObj := &s3.GetObjectInput{
            Bucket: aws.String(r2Bucket),
            Key:    aws.String(key),
        }
        obj, err := s3Client.GetObject(getObj)
        if err != nil {
            abortWithError(c, http.StatusNotFound, "File not found", err)
            return
        }
        defer obj.Body.Close()
        downloadFilename := filepath.Base(userFilePath)
        c.Header("Content-Disposition", fmt.Sprintf(`attachment; filename="%s"`, downloadFilename))
        c.Header("Content-Type", "application/octet-stream")
        logger.Printf("Serving file %s for download (from R2).", key)
        io.Copy(c.Writer, obj.Body)
        return
    }
    if _, statErr := os.Stat(fullStoragePath); os.IsNotExist(statErr) {
        abortWithError(c, http.StatusNotFound, "File not found", statErr)
        return
    } else if statErr != nil {
        abortWithError(c, http.StatusInternalServerError, "Error checking file status", statErr)
        return
    }
    downloadFilename := filepath.Base(userFilePath)
    c.Header("Content-Disposition", fmt.Sprintf(`attachment; filename="%s"`, downloadFilename))
    c.Header("Content-Type", "application/octet-stream")
    logger.Printf("Serving file %s for download.", fullStoragePath)
    c.File(fullStoragePath)
}

func handleDeleteFile(c *gin.Context) {
    randomID := c.Param("random_id")
    userFilePath, err := getSanitizedUserPath(c.Param("filepath"))
    if err != nil {
        targetErr := errors.New("filepath cannot be empty")
        if err.Error() == targetErr.Error() {
            userFilePath = ""
        } else {
            abortWithError(c, http.StatusBadRequest, "Invalid filepath for deletion", err)
            return
        }
    }
    var pathToOperateOn string
    var operationDescription string
    var r2Key string
    if userFilePath == "" {
        _, dirPath, errBuild := buildAndVerifyStoragePath(randomID, ".")
        if errBuild != nil {
            abortWithError(c, http.StatusInternalServerError, "Error accessing directory path for deletion", errBuild)
            return
        }
        pathToOperateOn = dirPath
        operationDescription = fmt.Sprintf("directory %s and all its contents", dirPath)
        absBasePath, _ := filepath.Abs(config.BaseStoragePath)
        absPathToOperate, _ := filepath.Abs(pathToOperateOn)
        if absPathToOperate == absBasePath {
            abortWithError(c, http.StatusForbidden, "Cannot delete base storage directory", nil)
            return
        }
        rel, _ := filepath.Rel(config.BaseStoragePath, pathToOperateOn)
        r2Key = filepath.ToSlash(rel)
    } else {
        fullStoragePath, _, errBuild := buildAndVerifyStoragePath(randomID, userFilePath)
        if errBuild != nil {
            abortWithError(c, http.StatusInternalServerError, "Error accessing file path for deletion", errBuild)
            return
        }
        pathToOperateOn = fullStoragePath
        operationDescription = fmt.Sprintf("file %s", userFilePath)
        rel, _ := filepath.Rel(config.BaseStoragePath, pathToOperateOn)
        r2Key = filepath.ToSlash(rel)
    }
    if config.StorageType == StorageR2 {
        if userFilePath == "" {
            prefix := randomID + "/"
            listInput := &s3.ListObjectsV2Input{
                Bucket: aws.String(r2Bucket),
                Prefix: aws.String(prefix),
            }
            err := s3Client.ListObjectsV2Pages(listInput, func(page *s3.ListObjectsV2Output, lastPage bool) bool {
                for _, obj := range page.Contents {
                    _, delErr := s3Client.DeleteObject(&s3.DeleteObjectInput{
                        Bucket: aws.String(r2Bucket),
                        Key:    obj.Key,
                    })
                    if delErr != nil {
                        logger.Printf("Failed to delete object %s: %v", *obj.Key, delErr)
                    }
                }
                return !lastPage
            })
            if err != nil {
                abortWithError(c, http.StatusInternalServerError, "Failed to delete directory in R2", err)
                return
            }
            logger.Printf("Successfully deleted directory %s and all its contents (R2).", prefix)
        } else {
            _, err := s3Client.DeleteObject(&s3.DeleteObjectInput{
                Bucket: aws.String(r2Bucket),
                Key:    aws.String(r2Key),
            })
            if err != nil {
                abortWithError(c, http.StatusInternalServerError, "Failed to delete file in R2", err)
                return
            }
            logger.Printf("Successfully deleted file %s (R2).", r2Key)
        }
        c.JSON(http.StatusOK, gin.H{"message": fmt.Sprintf("Successfully deleted %s", userFilePath)})
        return
    }
    if _, statErr := os.Stat(pathToOperateOn); os.IsNotExist(statErr) {
        abortWithError(c, http.StatusNotFound, fmt.Sprintf("Path %s not found for deletion", userFilePath), statErr)
        return
    } else if statErr != nil {
        abortWithError(c, http.StatusInternalServerError, "Error checking path status for deletion", statErr)
        return
    }
    if err := os.RemoveAll(pathToOperateOn); err != nil {
        abortWithError(c, http.StatusInternalServerError, fmt.Sprintf("Failed to delete %s", operationDescription), err)
        return
    }
    logger.Printf("Successfully deleted %s.", operationDescription)
    c.JSON(http.StatusOK, gin.H{"message": fmt.Sprintf("Successfully deleted %s", userFilePath)})
}

func handleGetMaxUploadSize(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "max_upload_size": config.MaxUploadSize,
    })
}

// --- Main ---

func main() {
    gin.SetMode(gin.ReleaseMode)
    r := gin.New()
    r.Use(gin.Logger())
    r.Use(gin.Recovery())
    if err := r.SetTrustedProxies(config.TrustedProxies); err != nil {
        logger.Fatalf("Failed to set trusted proxies: %v", err)
    }
    logger.Printf("Gin trusted proxies set to: %v", config.TrustedProxies)
    r.Use(func(c *gin.Context) {
        c.Header("X-Content-Type-Options", "nosniff")
        c.Header("X-Frame-Options", "DENY")
        c.Header("Content-Security-Policy", "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; object-src 'none'; img-src 'self' data:; font-src 'self' data:;")
        c.Header("X-XSS-Protection", "1; mode=block")
        c.Header("Referrer-Policy", "strict-origin-when-cross-origin")
        c.Next()
    })
    r.GET("/", func(c *gin.Context) {
        filePath := "./static/index.html"
        cwd, errCwd := os.Getwd()
        if errCwd != nil {
            logger.Printf("GET /: Could not get current working directory: %v", errCwd)
        } else {
            logger.Printf("GET /: Current working directory: %s", cwd)
        }
        absFilePath, errAbs := filepath.Abs(filePath)
        if errAbs != nil {
            logger.Printf("GET /: Could not resolve absolute path for %s: %v", filePath, errAbs)
        } else {
            logger.Printf("GET /: Attempting to serve index.html from absolute path: %s", absFilePath)
        }
        fileInfo, err := os.Stat(filePath)
        if os.IsNotExist(err) {
            logger.Printf("GET /: index.html NOT FOUND at %s (resolved to %s). CWD is %s. Ensure it's copied to the container and path is correct.", filePath, absFilePath, cwd)
            c.String(http.StatusNotFound, fmt.Sprintf("Error: index.html not found. Expected at %s relative to CWD (%s).", filePath, cwd))
            return
        } else if err != nil {
            logger.Printf("GET /: Error stating index.html at %s: %v", filePath, err)
            c.String(http.StatusInternalServerError, "Internal server error checking for index.html.")
            return
        }
        if fileInfo.IsDir() {
            logger.Printf("GET /: Path %s is a directory, not a file. Cannot serve index.html.", filePath)
            c.String(http.StatusNotFound, fmt.Sprintf("Error: Expected index.html to be a file, but found a directory at %s.", filePath))
            return
        }
        logger.Printf("GET /: Serving index.html from %s", filePath)
        c.Header("Cache-Control", "no-cache, no-store, must-revalidate")
        c.Header("Pragma", "no-cache")
        c.Header("Expires", "0")
        c.File(filePath)
    })
    r.GET("/config/max_upload_size", handleGetMaxUploadSize)
    r.GET("/favicon.ico", func(c *gin.Context) {
        logger.Printf("GET /favicon.ico: Returning 204 No Content.")
        c.Status(http.StatusNoContent)
    })
    r.POST("/", handleUploadPost)
    r.PUT("/*filepath", handleUploadPut)
    r.GET("/:random_id/*filepath", handleDownloadFile)
    r.DELETE("/:random_id/*filepath", handleDeleteFile)
    r.MaxMultipartMemory = config.MaxUploadSize
    logger.Println("Starting XTemp File Service on :5000...")
    if err := r.Run(":5000"); err != nil {
        logger.Fatalf("Failed to start server: %v", err)
    }
}
