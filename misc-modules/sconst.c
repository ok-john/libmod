#include <linux/module.h>


int MAJOR_VERSION = 1;
int MINOR_VERSION = 0;

EXPORT_SYMBOL(MAJOR_VERSION);
EXPORT_SYMBOL(MINOR_VERSION);

MODULE_DESCRIPTION("Version as exported symbols");
MODULE_AUTHOR("John S <john@sahhar.io>");
MODULE_LICENSE("GPL v2"); 

