#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/module.h>
            

#define VB_DEV_MAX 3
#define VB_DEV_NAME "vb"

static int vb_open(struct inode *inode, struct file *file);
static int vb_release(struct inode *inode, struct file *file);
static long vb_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
static ssize_t vb_read(struct file *file, char __user *buf, size_t count, loff_t *offset);
static ssize_t vb_write(struct file *file, const char __user *buf, size_t count, loff_t *offset);

MODULE_LICENSE("GPL");            
MODULE_DESCRIPTION("vb");
MODULE_AUTHOR("john-s <john@sahhar.io>");

// initialize file_operations
static const struct file_operations vb_fops = {
    .owner      = THIS_MODULE,
    .open       = vb_open,
    .release    = vb_release,
    .unlocked_ioctl = vb_ioctl,
    .read       = vb_read,
    .write       = vb_write
};

static int vb_open(struct inode *inode, struct file *file)
{
    printk("MYCHARDEV: Device open\n");
    return 0;
}

static int vb_release(struct inode *inode, struct file *file)
{
    printk("MYCHARDEV: Device close\n");
    return 0;
}

static long vb_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
    printk("MYCHARDEV: Device ioctl\n");
    return 0;
}

static ssize_t vb_read(struct file *file, char __user *buf, size_t count, loff_t *offset)
{
    printk("MYCHARDEV: Device read\n");
    return 0;
}

static ssize_t vb_write(struct file *file, const char __user *buf, size_t count, loff_t *offset)
{
    printk("MYCHARDEV: Device write\n");
    return 0;
}

// device data holder, this structure may be extended to hold additional data
struct mychar_device_data {
    struct cdev cdev;
};

// global storage for device Major number
static int dev_major = 0;

// sysfs class structure
static struct class *vb_class = NULL;

// array of mychar_device_data for
static struct mychar_device_data vb_data[VB_DEV_MAX];

void vb_init(void)
{
    int err, i;
    dev_t dev;

    // allocate chardev region and assign Major number
    err = alloc_chrdev_region(&dev, 0, VB_DEV_MAX, VB_DEV_NAME);

    dev_major = MAJOR(dev);

    // create sysfs class
    vb_class = class_create(THIS_MODULE, VB_DEV_NAME);

    // Create necessary number of the devices
    for (i = 0; i < VB_DEV_MAX; i++) {
        // init new device
        cdev_init(&vb_data[i].cdev, &vb_fops);
        vb_data[i].cdev.owner = THIS_MODULE;

        // add device to the system where "i" is a Minor number of the new device
        cdev_add(&vb_data[i].cdev, MKDEV(dev_major, i), 1);
        
        // create device node /dev/mychardev-x where "x" is "i", equal to the Minor number
        device_create(vb_class, NULL, MKDEV(dev_major, i), NULL, "%s-%d", VB_DEV_NAME, i);
    }
}

static int __init mod_vb(void)
{
		printk(KERN_ALERT "vb mod");
		return 0;
}

static void __exit umod_vb(void)
{
		printk(KERN_ALERT "vb umod");
}

module_init(mod_vb);
module_exit(umod_vb);
