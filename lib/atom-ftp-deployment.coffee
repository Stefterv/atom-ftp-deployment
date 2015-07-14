child_process = require('child_process')
path = require('path')
fs = require('fs')

project_directory = (file_dir) ->

    for dir in atom.project.getDirectories()

        if dir.contains(file_dir)

            return dir.path

    return file_dir

start_deployment = () =>

    file_path = atom.workspace.getActivePaneItem()?.buffer?.file?.path or ""
    file_dir = path.dirname(file_path)
    proj_dir = project_directory(file_dir)

    cmd = []

    cmd.push("start")
    cmd.push(read_option("php_url"))
    cmd.push(read_option("deploymentphp_url"))
    cmd.push(proj_dir + "\\" + read_option("deploymentini_name"))

    console.log(cmd.join(" "))

    child_process.exec(cmd.join(" "), cwd: null, (error, stdout, stderr) ->

      if error

            console.error(
                """
                ftp-deployment error when child_process.exec ->
                cmd = #{cmd.join(" ")}
                error = #{error}
                stdout = #{stdout}
                stderr = #{stderr}
                """
            )

    )


read_option = (name) ->

    atom.config.get("atom-ftp-deployment.#{name}")


build_command = (name) ->

    "atom-ftp-deployment:#{name}"


add_command = (name, f) ->

    atom.commands.add("atom-workspace", build_command(name), f)


module.exports =

    activate: (state) ->

        add_command("start-deployment", () => @start_deployment())

    start_deployment: ->

        start_deployment()

    config:

        php_url:

            title: "URL php.exe"
            type: "string"
            default: "php.exe"

        deploymentphp_url:

            title: "URL deployment.php"
            type: "string"
            default: "deployment.php"

        deploymentini_name:

            title: "Name deployment ini file"
            type: "string"
            default: "deployment.ini"
