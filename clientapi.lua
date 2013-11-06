REDNET_BROADCAST 	= 65535
MINENET_JOIN		= 65534

function open()
	local sides = {"left","right","front","back","top","bottom"}
	local modem = nil
	for (i=1,6,1) do
		if peripheral.isPresent(side[i]) then
			if (peripheral.getType(side[i]) == "modem") then
				modem = peripheral.wrap(side[i])
				if !modem.isWireless() then
					modem = nil
				end
			end
		end
	end
	assert(modem,"No Wireless Modem Attached")
	
	if !modem.isOpen(os.computerID()) then
		modem.open(os.computerID())
	end
	if !modem.isOpen(REDNET_BROADCAST) then
		modem.open(REDNET_BROADCAST)
	end
		
	modem.transmitt(MINENET_JOIN,os.computerID(),"MINENET_JOIN")
	local bTimeout = false
	local timeoutTimer = os.startTimer(5)
	local connectionChannel
	local serverDistance = nil
	while !bTimeout do
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent()
		if event == "modem_message" then
			nServers = nServers + 1
			if (serverDistance == nil) then
				serverDistance = senderDistance
			end
			if (serverDistance > senderDistance) then
				serverDistance = senderDistance
				connectionChannel = replyChannel
			end
		elseif event == "timer" then
			bTimeout = true
		end
	end
	assert(connectionChannel, "timeout no connection established")
	bTimeout = false
	local bConnected = false
	local errorMessage = nil
	timeoutTimer = os.startTimer(5)
	modem.transmitt(connectionChannel,os.computerID(),"ESTABLISH_CONNECTION")
	while (!bTimeout & !bConnected) do
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent()
		if (event == "modem_message" & senderChannel == connectionChannel & message == "CONECCTION_ESTABLISHED") then
			return connectionChannel
		elseif (event == "modem_message" & senderChannel == connectionChannel) then
			return nil, message
		elseif event == "timer" then
			bTimeout = true
		end
	end
end

function send()
	
end