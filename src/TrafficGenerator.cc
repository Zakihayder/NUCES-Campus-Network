#include "TrafficGenerator.h"

Define_Module(TrafficGenerator);

void TrafficGenerator::initialize()
{
    // ... (Keep your existing parameter reading and CBR/Bursty logic) ...

    pktsSentSignal     = registerSignal("pktsSent");
    pktsReceivedSignal = registerSignal("pktsReceived");
    eedSignal          = registerSignal("endToEndDelay");

    sendTimer = new cMessage("sendTimer");
    scheduleAt(simTime() + par("startTime"), sendTimer);
}

void TrafficGenerator::handleMessage(cMessage *msg)
{
    if (msg == sendTimer) {
        if (simTime() < par("stopTime")) {
            sendPacket();
            scheduleNextSend();
        }
    } else {
        // Receiver Side Logic
        cPacket *pkt = check_and_cast<cPacket *>(msg);
        if (pkt->hasPar("sendTime")) {
            simtime_t delay = simTime() - pkt->par("sendTime").doubleValue();
            emit(eedSignal, delay);
            emit(pktsReceivedSignal, 1);
        }
        delete pkt;
    }
}

void TrafficGenerator::sendPacket()
{
    cPacket *pkt = new cPacket("DataPacket");
    pkt->setByteLength(par("packetSize"));
    pkt->addPar("srcAddr")  = par("ipAddress").stringValue();
    pkt->addPar("destAddr") = par("destAddr").stringValue();
    pkt->addPar("sendTime") = simTime().dbl(); // Essential for delay calculation

    emit(pktsSentSignal, 1);
    send(pkt, "out");
}




/*
#include "TrafficGenerator.h"

Define_Module(TrafficGenerator);

void TrafficGenerator::initialize()
{
    profile      = par("trafficProfile").stdstringValue();
    packetSize   = par("packetSize");
    sendInterval = par("sendInterval");
    burstSize    = par("burstSize");
    burstGap     = par("burstGap");
    destAddr     = par("destAddr").stdstringValue();
    srcAddr      = par("srcAddr").stdstringValue();
    startTime    = par("startTime").doubleValue();
    stopTime     = par("stopTime").doubleValue();

    seqNum     = 0;
    burstCount = 0;

    pktsSentSignal      = registerSignal("pktsSent");
    pktsReceivedSignal  = registerSignal("pktsReceived");
    endToEndDelaySignal = registerSignal("endToEndDelay");

    EV_INFO << "[TG] Init " << getFullPath()
            << "  profile=" << profile
            << "  dest="    << destAddr
            << "  pktSize=" << packetSize << "B"
            << "  start="   << startTime  << "s"
            << "  stop="    << stopTime   << "s\n";

    sendTimer = new cMessage("sendTimer");
    scheduleAt(simTime() + startTime, sendTimer);
}

void TrafficGenerator::handleMessage(cMessage *msg)
{
    if (msg == sendTimer) {
        if (simTime() >= stopTime) {
            EV_INFO << "[TG] " << getFullPath()
                    << " reached stopTime — halting.\n";
            return;
        }
        sendPacket();
        scheduleNextSend();

    } else {
        // Incoming packet arriving on ethg$i
        if (msg->hasPar("sendTime")) {
            double delay = SIMTIME_DBL(simTime()) - msg->par("sendTime").doubleValue();
            emit(endToEndDelaySignal, delay);
            EV_INFO << "[TG] RCV pkt #"
                    << (int)msg->par("seqNum").longValue()
                    << "  delay=" << delay * 1000.0 << " ms\n";
        }
        emit(pktsReceivedSignal, (long)1);
        delete msg;
    }
}

void TrafficGenerator::sendPacket()
{
    cPacket *pkt = new cPacket("TG_DataPacket");
    pkt->setByteLength(packetSize);

    pkt->addPar("srcAddr")  = srcAddr.c_str();
    pkt->addPar("destAddr") = destAddr.c_str();
    pkt->addPar("seqNum")   = (long)seqNum;
    pkt->addPar("sendTime") = SIMTIME_DBL(simTime());

    EV_INFO << "[TG] SND #" << seqNum
            << "  src="  << srcAddr
            << "  dst="  << destAddr
            << "  size=" << packetSize << "B"
            << "  t="    << simTime()  << "s\n";

    seqNum++;
    emit(pktsSentSignal, (long)1);

    // Send through the OUTPUT half of the inout gate
    send(pkt, "ethg$o");
}

void TrafficGenerator::scheduleNextSend()
{
    if (profile == "CBR") {
        scheduleAt(simTime() + sendInterval, sendTimer);

    } else if (profile == "Bursty") {
        burstCount++;
        if (burstCount < burstSize) {
            scheduleAt(simTime() + 0.001, sendTimer);
        } else {
            burstCount = 0;
            scheduleAt(simTime() + burstGap, sendTimer);
        }
    } else {
        EV_WARN << "[TG] Unknown profile '" << profile << "' — defaulting to CBR\n";
        scheduleAt(simTime() + sendInterval, sendTimer);
    }
}

void TrafficGenerator::finish()
{
    EV_INFO << "[TG] === SUMMARY " << getFullPath() << " ===\n"
            << "  Packets sent : " << seqNum   << "\n"
            << "  Profile      : " << profile  << "\n"
            << "  Destination  : " << destAddr << "\n";
    recordScalar("totalPacketsSent", seqNum);
}*/
