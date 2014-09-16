#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include <time.h>
#include <unistd.h>

#include "minzip/Zip.h"

int main(int argc, char **argv)
{
    if (argc < 4) {
        fprintf(stderr, "usage: %s <file.zip>\n", argv[0]);
        return 0;
    }
    char *package_data = argv[1];
    char *zip_path = argv[2];
    char *dest_path = argv[3];
    ZipArchive za;
    int err = mzOpenZipArchive(package_data, &za);
    if (err) {
        fprintf(stderr, "failed to open package %s: %s\n",
                package_data, strerror(err));
        return 1;
    }

    time_t clock = time(NULL);
    struct utimbuf timestamp = { clock, clock };

    bool success = mzExtractRecursive(&za, zip_path, dest_path,
                                      MZ_EXTRACT_FILES_ONLY, &timestamp,
                                      NULL, NULL, NULL);
    if (!success) {
        fprintf(stderr, "Extract error!\n");
        return 1;
    }
    printf("Extract successfuly!\n");

    return 0;
}
