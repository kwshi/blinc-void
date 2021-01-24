# vi: ft=dockerfile
FROM "scratch"
ARG "void_rootfs_filename"
ADD ["download/$void_rootfs_filename", "/"]
