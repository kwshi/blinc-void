# vi: ft=dockerfile
FROM "scratch"
ARG "void_rootfs_filename"
ADD ["build/download/$void_rootfs_filename", "/"]
