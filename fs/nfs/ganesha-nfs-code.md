//src/MainNFSD/nfs_main.c
```c
int main() {
//...
// parsing options with getopt
//...
nfs_init_init();
//...
// set up for the singal handler
//...
start_fsals();
//...
// Load Data Server entries from parsed file 
// returns the number of DS entries
dsc = ReadDataServers(config_struct, &err_type);i
//..
// Load export entries from parsed file
// returns the number of export entries
rc = ReadExports(config_struct, &err_type);
//...
config_Free(config_struct);
// Everything seems to be OK! We can now start service threads
nfs_start(&my_nfs_start_info);
return 0;
}


//fsal_manager.c
//...
static struct fsal_module *new_fsal;

void start_fsals(void) {
  load_state=idle;
  load_fsal_static("MDCACHE", md_cache_fsal_init);
  load_fsal_static("PSEUDO", pseudo_fsal_init);
}

static void load_fsal_static(const char *name, void (*init)(void)){
  //...
  struct fsal_module *fsal;
  //...
  init();  // now it is the modules' turn to register itself
  //...
  //..
  fsal = new_fsal;  // global; recover handle form .ctor and poison agian
  new_fsal = NULL;
  //...
}

init register_fsal(struct fsal_module *fsal_hdl, const cahr *name, ..., uint8_t fsal_id){
  //...
  new_fsal = fsal_hdl;
  //...
  // init ops vectors to system wide defaults from FSAL/default_methods.c
  memcpy(&fsal_hdl->m_ops, &def_fsal_ops, sizeof(struct fsal_ops));
  //...
  glist_add_tail(&fsal_list, &fsal_hdl->fsals);
  //...
}

int fsal_load_init(void *node, const char *name, struct fsal_module **fsal_hdl,.){
  //...
  *fsal_hdl = lookup_fsal(name); // e.g. VFS in block FSAL{name = VFS}
  if(*fsal_hdl == NULL){
    int retval;
    config_file_t myconfig;
    retval = load_fsal(name, fsal_hdl);
    //...
    op_ctx->fsal_module = *fsal_hdl;
    myconfig = get_parse_root(node);
    status = (*fsal_hdl)->m_ops.init_config(*fsal_hdl,myconfig,err_type);
    //...
  }
  return 0;
}

// Load the fsal's shared object.
// The dlopen() will trigger a .init constructor which will do the actual
// registration. after a sucessful load, the returned handle needs to be
// "put" back after any other initialization is done.
int load_fsal(const char *name, struct fsal_module **fsal_hdl_p) {
  //...
  struct fsal_module *fsal;
  //...
  // Loading FSAL <VFS> with /usr/lib/ganesha/libfsal<vfs>.so
  // path = /usr/lib/ganesha/libfsalvfs.so
  // dlopen will trigger a .init ctor (e.g vfs_init)
  dl = dlopen(path, RTLD_NOW | RTLD_LOCAL | RTLD_DEEPBIND);
  //...
  fsal = new_fsal; // recover handle from .ctor and poison again
  new_fsal = NULL;

  fsal_get(fsal);  // take initial ref so we can pass it back...
  fsal->path = dl_path;
  fsal->dl_hanlde = dl;
  *fsal_hdl_p = fsal;
  //...
  return 0;
}
  

//src/include/fsal_api.h
// Get a reference to a module
static inline void fsal_get(struct fsal_module *fsal_hdl){
  (void) atomic_inc_int32(&fsal_hdl->refcount);
  assert(fsal_hdl->refcount > 0);
}

//src/include/FSAL/fsal_init.h
/**
@brief Initializer macro
*
* Every FSAL module has an initializer.  any function labeled as
* MODULE_INIT will be called in order after the module is loaded and
* before dlopen returns.  This is where you register your fsal.
*
* The initializer function should use register_fsal to initialize
* public data and get the default operation vectors, then override
* them with module-specific methods.
*/

#define MODULE_INIT __attribute__((constructor))

/**
* @brief Finalizer macro
*
* Every FSAL module *must* have a destructor to free any resources.
* the function should assert() that the module can be safely unloaded.
* However, the core should do the same check prior to attempting an
* unload. The function must be defined as void foo(void), i.e. no args
* passed and no returns evaluated.
*/

#define MODULE_FINI __attribute__((destructor))


//src/FSAL/FSAL_VFS/main.c
/* Module initialization.
*Called by dlopen() to register the module
* keep a private pointer to me in myself
*/

/* my module private storage
*/
static struct vfs_fsal_module VFS;

/* linkage to the exports and handle ops initializers
*/
MODULE_INIT void vfs_init(void)
{
  int retval;
  struct fsal_module *myself = &VFS.fsal;
  
  retval = register_fsal(myself, myname, FSAL_MAJOR_VERSION,
  FSAL_MINOR_VERSION, FSAL_ID_VFS);
  if (retval != 0) {
  fprintf(stderr, "VFS module failed to register");
  return;
  }
  myself->m_ops.create_export = vfs_create_export;
  myself->m_ops.init_config = init_config;
}

MODULE_FINI void vfs_unload(void)
{
  int retval;
  
  retval = unregister_fsal(&VFS.fsal);
  if (retval != 0) {
  fprintf(stderr, "VFS module failed to unregister");
  return;
  }
}


//md_cache_main.c
void mdcache_fsal_init(void)
{
  int retval;
  struct fsal_module *myself = &MDCACHE.fsal;
  
  retval = register_fsal(myself, mdcachename, FSAL_MAJOR_VERSION,
  FSAL_MINOR_VERSION, FSAL_ID_NO_PNFS);
  if (retval != 0) {
    fprintf(stderr, "MDCACHE module failed to register");
    return;
  }
  /*myself->m_ops.create_export = mdcache_fsal_create_export;*/
  myself->m_ops.init_config = mdcache_fsal_init_config;
  myself->m_ops.unload = mdcache_fsal_unload;
}

//src/support/ds.c
/**
@brief Table of DS block parameters
*
* NOTE: the Client and FSAL sub-blocks must be the *last*
* two entries in the list.  This is so all other
* parameters have been processed before these sub-blocks
* are processed.
*/

static struct config_item pds_items[] = {
  CONF_ITEM_UI16("Number", 0, UINT16_MAX, 0,
  fsal_pnfs_ds, id_servers),
  CONF_RELAX_BLOCK("FSAL", fsal_params,
      fsal_init, fsal_cfg_commit,    // <<<<< 
      fsal_pnfs_ds, fsal), CONFIG_EOL
}; 

/**
* @brief Top level definition for each DS block
*/
static struct config_block pds_block = {
  .dbus_interface_name = "org.ganesha.nfsd.config.ds.%d",
  .blk_desc.name = "DS",
  .blk_desc.type = CONFIG_BLOCK,
  .blk_desc.u.blk.init = pds_init,
  .blk_desc.u.blk.params = pds_items,    // <<<<<
  .blk_desc.u.blk.commit = pds_commit,
  .blk_desc.u.blk.display = pds_display
};

int ReadDataServers(config_file_t in_config,
        struct config_error_type *err_type) {
int rc;

rc = load_config_from_parse(in_config,
                            &pds_block,   // <<<<<
                            NULL,
                            false,
                            err_type);
if (!config_error_is_harmless(err_type))
  return -1;

return rc;
}

///src/support/exports.c
/**
@brief Read the export entries from the parsed configuration file.
*
* @param[in]  in_config    The file that contains the export list
*
* @return A negative value on error,
*         the number of export entries else.
*/
int ReadExports(config_file_t in_config,
    struct config_error_type *err_type)
{
int rc, num_exp;

rc = load_config_from_parse(in_config,
                            &export_defaults_param,
                            NULL,
                            false,
                            err_type);
if (rc < 0) {
  LogCrit(COMPONENT_CONFIG, "Export defaults block error");
  return -1;
}

num_exp = load_config_from_parse(in_config,
                                  &export_param,
                                  NULL,
                                  false,
                                  err_type);
//...
}

static init fsal_cfg_commit(void *node, void *link_mem, void *self_struct, err_type) {
  struct fsal_export **exp_hdl = link_mem;
  struct gsh_export *export = container_of(exp_hdl, struct gsh_export, fsal_export);
  struct fsal_args *fp = self_struct;
  struct fsal_module_*fsal;
  //...
  init_root_op_context(&root_op_context, export, NULL, 0, 0, UNKNOW_REQUEST);
  errcnt = fsal_load_init(node, fp->name, export, NULL, 0, 0, UNKNOW_REQUEST);
  //...
  clean_export_paths(export);
  // The handle cache (currently MDCACHE) must be at the top of the statck of 
  // FSALS. To achieve this, call directly into MDCACHE, passing the sub-FSAL's
  // fsal_module.
  // MDCACHE will statck itself on top of that FSAL, continuing down the chain.
  status = mdcache_fsal_create_export(fsal, node, err_type, &fsal_up_top);

  //...
  export->fsal_export = root_op_context.req_ctx.fsal_export;

  // We are connecte up to the fsal side. Now validate maxread/write with
  // fsal params
  // ...

  release_root_op_context();
  //...
}

//src/config_parsing/config_parsing.c
//load_config_from_parse 
// -> proc_block -> fsal_load_init
// ...
// glist_for_each {
// proc_block->fsal_load_init
// ...
// }
//
// do_block_load
// while (node != NULL) {
//   next_node = lookup_next_mode(...)
//   //...
//   switch(item->type) {
//     case CONFIG_NULL:
//       break;
//     //...
//     case CONFIG_BLOCK:
//       if(!proc_block(node, item, param_addr, err_type))  // <<<<
//         config_proc_error(...)
//       break;
//     //...
//     default:
//  }
//}
```
