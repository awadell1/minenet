https://raw.github.com/awadell1/minenet/master/clientapi.lua
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
	assert(modem,"NO_WIRELESS_MODEM")
	
	if !modem.isOpen(os.computerID()) then
		modem.open(os.computerID())
	end
	if !modem.isOpen(REDNET_BROADCAST) then
		modem.open(REDNET_BROADCAST)
	end
		
	modem.transmitt(MINENET_JOIN,os.computerID(),"MINENET_JOIN")
	local bTimeout = false
	local timeoutTimer = os.startTimer(5)
	local nMinenetChannel
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
				nMinenetChannel = replyChannel
			end
		elseif event == "timer" then
			bTimeout = true
		end
	end
	assert(nMinenetChannel, "TIMEOUT")
	bTimeout = false
	local bConnected = false
	local errorMessage = nil
	timeoutTimer = os.startTimer(5)
	modem.transmitt(nMinenetChannel,os.computerID(),"ESTABLISH_CONNECTION")
	while (!bTimeout & !bConnected) do
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent()
		if (event == "modem_message" & senderChannel == nMinenetChannel & message == "CONECCTION_ESTABLISHED") then
			return nMinenetChannel
		elseif (event == "modem_message" & senderChannel == nMinenetChannel) then
			return nil, message
		elseif event == "timer" then
			bTimeout = true
		end
	end
end

function getConnection(TargetComputer,nMinenetChannel)
	assert(TargetComputer)
	assert(nMinenetChannel)
	strServerRequest = textutils.serialize({"REQUEST_ROUTING_TABLE",os.computerID(),TargetComputer})
	timeoutTimer = os.startTimer(5)
	modem.transmitt(nMinenetChannel,os.computerID(),ServerRequest)
	while true do
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent()
		if (event == "modem_message" & senderChannel == nMinenetChannel) then
			local aServerResponse = untextutils.serialize(message)
			if (aServerResponse[1] == "ROUTING_SUCCESS") then
				return table.remove(aServerResponse,1)
			elseif (aServerResponse[1] == "ROUTING_FAILURE") then
				error(aServerResponse)
			end
		elseif event == "timer" then
			error("TIMEOUT")
		end
	end
end

function send(nMinenetChannel, RoutingTable, message)
	assert(nMinenetChannet = tonumber(nMinenetChannet))
	--Generate Random PacketID
	math.randomseed(os.time())
	nPacketID = math.random(65536)
	nRouteLocation = 1
	strPacket = textutils.serialize({"REQUEST_SEND_PACKET",RoutingTable,nRouteLocation,nPacketID,message})
	modem.transmitt(nMinenetChannel,os.computerID(),ServerRequest)
	return nPacketID
end

