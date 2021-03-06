local ProgramName = { ... }
if (#ProgramName ~= 1) then
else
	print("Usage: update <program name>")
	return
end
program = fs.open(ProgramName,"r")
FileURL = program.read()
program.close()

http.request(FileURL)
local requesting = true
while requesting do
	local event, url, sourceText = os.pullEvent()
	if event == "http_success" then
		local respondedText = sourceText.readAll()
		program = fs.open(ProgramName,"w")
		program.write(respondedText)
		program.close()
		print("Updated: "+ ProgramName)
		requesting = false
	elseif event == "http_failure" then
		print("ERROR: Could not update " + ProgramName)
		requesting = false
	end
 end
 
 return
