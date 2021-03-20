# Dependencies

To build qemu with whpx acceleration the following headers from the Windows SDK are required:

- WinHvEmulation.h
- WinHvPlatform.h
- WinHvPlatformDefs.h

These headers can be found at `C:\Program Files (x86)\Windows Kits\10\Include\<your_windows_version>\um` and should be copied to the folder with Dockerfile.

# Build QEMU with the dockerfile

Run `docker build .`

Copy from container to host:
```
id=$(docker create <image_id>)
docker cp $id:/qemu_win <dest_folder>
docker rm -v $id
```

# Run qemu with virgl (GLES)

`qemu-system-x86_64 ... -vga virtio -display sdl,gl=es`
