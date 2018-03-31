
/*
 *   reading the Extended Filesystem v2 (ext2) superblock
 *   Orestes Leal Rodriguez, 2018
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>


#define    EXT2_SUPERBLOCK_SIZE     1024   /*   size of the ext2 superblock  */
#define    EXT2_MAGIC_OFFSET        56     /*   offset into the superblock of the magic number */

int main (int argc, char *argv[]) {

    ssize_t rd;
    int fd;
    off_t seek;
    char *ext2_superblock_mem = NULL;
    char buf[2], *buffer = buf;

    /*   ext2 magic number, if offset 56 into the superblock is this value (2 bytes)
         then the filesystem is the extended filesystem v2 */
    unsigned char ext2_magic_no[2] = {0x53, 0xef};


    if (argc < 2) {
        fprintf(stderr, "Error, not enough arguments, provide the disk as the first parameter\n");
        return -1;
    }


    /*   open the device  */
    fd = open(argv[1], O_RDONLY);
    if (fd == -1)  {
        fprintf(stderr, "Error: opening device or file\n");
        return -1;
    }

    /*   allocate memory for the process and copy the superblock there 1024 bytes  */
    if ((ext2_superblock_mem = malloc(EXT2_SUPERBLOCK_SIZE)) == NULL) {
        fprintf(stderr, "Cannot allocate memory for copying the ext2 superblock\n");
        return -1;
    }

    /*  seek into the file to offset 1024 in preparation to copy the superblock */
    if ((seek = lseek(fd, 1024, SEEK_SET)) == -1) {
        fprintf(stderr, "cannot seek into the descriptor file for %s\n", argv[1]);
        return -1;
    }


    /*  copy the full superblock to memory  */
    if ((rd = read(fd, ext2_superblock_mem, EXT2_SUPERBLOCK_SIZE)) == -1) {
        fprintf(stderr, "Error reading the file descriptor to copy the superblock into memory\n");
        return -1;
    }

    /*   do we have a correct magic number?  */
    if (memcmp(ext2_superblock_mem + EXT2_MAGIC_OFFSET, ext2_magic_no, 2) == 0) {
        printf("ext2 magic is correct on the superblock\n");
    }

    close(fd);
    free(ext2_superblock_mem);
    
    return 0;
}

/*
    super: start address of the superblock 
*/
void *get_superblock_info (void *super) {



}