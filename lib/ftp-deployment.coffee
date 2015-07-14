child_process = require('child_process')
path = require('path')
fs = require('fs')


interpolate = (s, o) ->

    s.replace(
        /{([^{}]*)}/g,
        (a, b) -> if typeof(o[b]) in ["string", "number"] then o[b] else a
    )


strip = (s) ->

    s.replace(/^\s+|\s+$/g, "")


project_directory = (file_dir) ->

    for dir in atom.project.getDirectories()

        if dir.contains(file_dir)

            return dir.path

    return file_dir


git_directory = (file_dir) ->

    path_info = path.parse(path.join(file_dir, "fictive"))
    while path_info.root != path_info.dir

        if fs.existsSync(path.join(path_info.dir, ".git"))

            return path_info.dir

        path_info = path.parse(path_info.dir)

    return file_dir


start_deployment = () =>

    file_path = atom.workspace.getActivePaneItem()?.buffer?.file?.path or ""
    file_dir = path.dirname(file_path)
    proj_dir = project_directory(file_dir)
    git_dir = git_directory(file_dir)

    cmd = [terminal]
    if command and file_path

        cmd.push(exec_arg)
        cmd.push(command)

    parameters =

        working_directory: file_dir
        project_directory: proj_dir
        git_directory: git_dir
        file_path: file_path

    cmd_line = interpolate(cmd.join(" "), parameters)
    child_process.exec(cmd_line, cwd: exec_cwd, (error, stdout, stderr) ->

        if error

            console.error(
                """
                ftp-deployment error when child_process.exec ->
                cmd = #{cmd_line}
                error = #{error}
                stdout = #{stdout}
                stderr = #{stderr}
                """
            )

    )


read_option = (name) ->

    atom.config.get("ftp-deployment.#{name}")


build_command = (name) ->

    "ftp-deployment:#{name}"


add_command = (name, f) ->

    atom.commands.add("atom-workspace", build_command(name), f)


module.exports =

    activate: (state) ->

        add_command("start-deployment", () => @start_deployment())

    start_deployment: ->

        start_deployment()
