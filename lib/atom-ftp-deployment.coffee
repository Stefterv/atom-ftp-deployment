child_process = require('child_process')
{CompositeDisposable, BufferedProcess} = require 'atom'
path = require('path')
fs = require('fs')

project_directory = (file_dir) ->

    for dir in atom.project.getDirectories()

        if dir.contains(file_dir)

            return dir.path

    return file_dir

start_deployment = () =>
  #atom automatically escapes for windows with BufferedProcess so this is the universal method
  file_path = atom.workspace.getActivePaneItem()?.buffer?.file?.path or ""
  file_dir = path.dirname(file_path)
  proj_dir = project_directory(file_dir)
  command = "php";
  args = []
  args.push(read_option("deploymentphp_url"));
  args.push(proj_dir + "/" + read_option("deploymentini_name"))
  options = {
    cwd: proj_dir
  }
  stdout = (output) ->
    console.log(output)
  stderr = (output) ->
    console.error(output)
  exit = (code) ->
    console.log("Error code: #{code}")
    if code == 0
      atom.notifications.addSuccess("Deployed!",{ dismissable: true });
  console.log("Running command #{command} #{args.join(" ")}")
  process = new BufferedProcess({command, args, options, stdout, stderr, exit})

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
