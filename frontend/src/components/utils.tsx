async function bytesToBase64DataUrl(bytes, mimeType = "application/octet-stream") {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result);
        reader.onerror = error => reject(error);
        reader.readAsDataURL(new Blob([bytes], {type: mimeType}));
    });
}

export { bytesToBase64DataUrl };