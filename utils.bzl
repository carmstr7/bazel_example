""" 
This is not currently working, so I have to use the symlinking section below to achieve a similar result
def _impl_filter(ctx):
    in_dir = ctx.files.srcs[0]
    suffix = ctx.attr.suffix
    generated_files = depset([in_dir])
    
    return [ x for x in generated_files.to_list() if x.path.endswith(suffix) ]
    
filter = rule (
    implementation = _impl_filter,
    attr = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True
        },
        "suffix": attr.string(mandatory = True),
    },
    doc = "Something to filter"
)
""""


# Using soft links to filter out suffix (especially cpp sources)
def _impl_symlinking(ctx):
    in_dir = ctx.files.srcs[0]
    suffix = ctx.attr.suffix
    out_dir = ctx.actions.declare_directory(in_dir.basename + suffix)
    
    ctx.actions.run_shell(
        outputs = [ out_dir ],
        inputs = [ in_dir ],
        progress_message = "Symlinking files since filter is not working...",
        command = """
            set -e -o pipefail
            cp -s $(realpath {in_dir}/*{suffix} $(realpath {out_dir})
        """.format(
            in_dir = in_dir.path, suffix = suffix, out_dir = out_dir.path
    
    return DefaultInfo(files = depset([out_dir]))
    
symlinking = rule (
    implementation = _impl_symlinking,
    attr = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True
        },
        "suffix": attr.string(mandatory = True),
    },
    doc = "Using symlink to filter out the files ending with suffix to be used in cc_library"
)

def _impl_doaction(ctx):
    var1 = ...
    var2 = ...
    var3 = ...
    var4 = ...
    var5 = ...
    ...
    tool = ctx.files_tool[0]
    out_dir = ctx.actions.declare_directory("FolderA")
    args = ctx.actions.args()
    args.add(var4)
    args.add_all([out_dir])
    
    ctx.actions.run_shell(
        outputs = [out_dir],
        inputs = [ var1, var2, stuff... ],
        progress_message = "Files for {} is being generated here".format(out_dir.path),
        command = """
            ...
            out_dir = {out_dir},
            tool = {tool},
            args = {args},
            ...
            
            $tool $args -o $out_dir # this is working fine, since I can ls the contents below
            ls -1 $out_dir
        """.format(
            ...,
            out_dir = out_dir,
            tool = tool,
            ...
        )
    
    # Everything is working correctly up to here, files are generated as needed in this callback
    
    generated_files = depset([out_dir])
    
    return [ DefaultInfo(files = generated_files) ] # This returns correctly with items in FolderA
    
    ## Other returns I've tried
    """
    return [ 
        DefaultInfo(files = generated_files),
        OutputGroupInfo(
            files = generated_files,
            source_files = depset([ x for x in generated_files.to_list() if x.path.endswith(".cpp") ]),
            header_files = depset([ x for x in generated_files.to_list() if x.path.endswith(".h") ])
        )
    ]
    
    return [ x for x in generated_files.to_list() if x.path.endswith(".cpp") ]
    """
    

doaction = rule (
    implementation = _impl_doaction,
    attr = {
        "args": attr.string_dict( mandatory = True ),
        "_tool": attr.label(
            default = Label("@Some//:tool"),
            execuate True,
            cfg = "host",
            allow_files = True,
        },
        "srcs": attr.label_list(mandatory = True, allow_files = True)
    },
    doc = "Main action done from this call"
)
