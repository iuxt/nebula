# XTemp File Hub

A simple, fast, and modern temporary file sharing service. Upload, download, copy link, and delete files easily. Files are automatically deleted after 24 hours.

## Features

- Drag & drop or click to upload files
- Download, copy link, or delete your file after upload
- Command line (curl) upload supported
- All file types supported (max size configurable)
- Files auto-delete after 24 hours

## Usage

### Web Interface

1. Open the website in your browser.
2. Read and accept the terms by typing `ACCEPT`.
3. Drag & drop a file or click the upload area to select a file.
4. Click **Start Upload**.
5. After upload, use the **Download**, **Copy Link**, or **Delete File** buttons as needed.
6. Click **Return to Home** to upload another file.

### Command Line Example

You can upload files using `curl`:

```sh
# Method 1: Simple PUT
curl -T example.txt http://your-server.com

# Method 2: Multipart POST
curl -X POST -F "file=@example.txt" http://your-server.com/
```

After upload, you will receive a download link in the response.

To delete a file (replace `<file_url>` with your actual file link):

```sh
curl -X DELETE <file_url>
```

## License

MIT
