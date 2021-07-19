#include <linux/list.h>
#include <linux/slab.h>
#include <linux/string.h>
#include <linux/mutex.h>
#include <asm/errno.h>
#include <linux/init.h>
#include <linux/module.h>
#define MAX_CACHE_SIZE 10
#define ROOT_CACHE 0
#define ROOT_CACHE_NAME 110

struct object
{
        struct list_head list;
        int id;
        char name[32];
        int popularity;
};

/* Protects the cache, cache_num, and the objects within it */
static DEFINE_MUTEX(cache_lock);
static LIST_HEAD(cache);
static unsigned int cache_num = 0;

/* Must be holding cache_lock */
static struct object *__cache_find(int id)
{
        struct object *i;

        list_for_each_entry(i, &cache, list)
                if (i->id == id) {
                        i->popularity++;
                        return i;
                }
        return NULL;
}

/* Must be holding cache_lock */
static void __cache_delete(struct object *obj)
{
        BUG_ON(!obj);
        list_del(&obj->list);
        kfree(obj);
        cache_num--;
}

/* Must be holding cache_lock */
static void __cache_add(struct object *obj)
{
        list_add(&obj->list, &cache);
        if (++cache_num > MAX_CACHE_SIZE) {
                struct object *i, *outcast = NULL;
                list_for_each_entry(i, &cache, list) {
                        if (!outcast || i->popularity < outcast->popularity)
                                outcast = i;
                }
                __cache_delete(outcast);
        }
}

int cache_add(int id, const char *name)
{
        struct object *obj;

        if ((obj = kmalloc(sizeof(*obj), GFP_KERNEL)) == NULL)
                return -ENOMEM;

        strlcpy(obj->name, name, sizeof(obj->name));
        obj->id = id;
        obj->popularity = 0;

        mutex_lock(&cache_lock);
        __cache_add(obj);
        mutex_unlock(&cache_lock);
        return 0;
}

void cache_delete(int id)
{
        mutex_lock(&cache_lock);
        __cache_delete(__cache_find(id));
        mutex_unlock(&cache_lock);
}

int cache_find(int id, char *name)
{
        struct object *obj;
        int ret = -ENOENT;

        mutex_lock(&cache_lock);
        obj = __cache_find(id);
        if (obj) {
                ret = 0;
                strcpy(name, obj->name);
        }
        mutex_unlock(&cache_lock);
        return ret;
}


static int __init mod_slock(void)
{
        printk(KERN_ALERT "slockinit");
        return 0;
}

static void __exit umod_slock(void)
{
        printk(KERN_ALERT "slock exit");
}
MODULE_DESCRIPTION("A simple cache");
MODULE_AUTHOR("John S <john@sahhar.io>");
MODULE_LICENSE("GPL v2");
module_exit(umod_slock);
module_init(mod_slock);

