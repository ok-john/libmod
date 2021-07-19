#include <linux/module.h>
#include <linux/init.h>
#define MOD_NS "sys"
#define MOD_NA "utils"

static int __init my_init(void)
{
    printk(KERN_INFO "%s", strcat(MOD_NS, MOD_NA));
    return 0;
}

static void __exit my_exit(void)
{
        printk(KERN_INFO "Removing sysutils");
}

module_init(my_init);
module_exit(my_exit);

MODULE_DESCRIPTION("System Utilities");
MODULE_AUTHOR("John S <john@sahhar.io>");
MODULE_LICENSE("GPL v2");

