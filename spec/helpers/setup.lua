-- Add the project directory to the module search path
local project_dir = os.getenv("PWD") or io.popen("pwd"):read("*l")
package.path = project_dir .. "/?.lua;" .. project_dir .. "/?/init.lua;" .. package.path