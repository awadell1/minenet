https://raw.github.com/awadell1/minenet/master/serverapi.lua
REDNET_BROADCAST 	= 65535
MINENET_JOIN		= 65534

--Server Communication Packet Format:
--1:PacketID
--2:Command Type
--3:Channel to Respond On
--4:Arguments

function newClient()
	
end

function Intialization()
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
	assert(modem,"NO_WIRELESS_MODEM")
	
	if !modem.isOpen(os.computerID()) then
		modem.open(os.computerID())
	end
	if !modem.isOpen(MINENET_JOIN) then
		modem.open(MINENET_JOIN)
	end
	if !modem.isOpen(REDNET_BROADCAST) then
		modem.open(REDNET_BROADCAST)
	end
		
	modem.transmitt(MINENET_JOIN,os.computerID(),"MINENET_JOIN_SERVER")
	local bTimeout = false
	local timeoutTimer = os.startTimer(5)
	local nMinenetServers = {}
	local nServers = 0
	while !bTimeout do
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent()
		if event == "modem_message" then
			Packet = textutils.unseralize(message)
			if Packet[
		elseif event == "timer" then
			bTimeout = true
		end
	end
end

function getPAcketID()
	return math.random(65536)
end
