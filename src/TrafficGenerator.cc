#include "TrafficGenerator.h"

Define_Module(TrafficGenerator);

void TrafficGenerator::initialize()
{
    // Read parameters from ini
    profile      = par("trafficProfile").stdstringValue();
    packetSize   = par("packetSize");
    sendInterval = par("sendInterval");
    burstSize    = par("burstSize");
    burstGap     = par("burstGap");
    destAddr     = par("destAddr").stdstringValue();
    startTime    = par("startTime");
    stopTime     = par("stopTime");

    seqNum     = 0;
    burstCount = 0;
    inBurst    = true;

    pktsSentSignal = registerSignal("pktsSent");

    EV_INFO << "[TrafficGenerator] Profile=" << profile
            << " destAddr=" << destAddr << "\n";

    // Schedule first send
    sendTimer = new cMessage("sendTimer");
    scheduleAt(simTime() + startTime, sendTimer);
}

void TrafficGenerator::handleMessage(cMessage *msg)
{
    if (msg == sendTimer) {
        if (simTime() >= stopTime) {
            EV_INFO << "[TrafficGenerator] Stop time reached.\n";
            return;   // stop sending
        }
        sendPacket();
        scheduleNextSend();
    }
}

void TrafficGenerator::sendPacket()
{
    // Create packet
    cPacket *pkt = new cPacket("DataPacket");
    pkt->setByteLength(packetSize);

    // Attach metadata as parameters
    pkt->addPar("srcAddr")   = "10.0.1.10";   // generic source
    pkt->addPar("destAddr")  = destAddr.c_str();
    pkt->addPar("seqNum")    = seqNum;
    pkt->addPar("sendTime")  = simTime().dbl();

    EV_INFO << "[TG] Sending pkt #" << seqNum
            << " to " << destAddr
            << " size=" << packetSize << "B"
            << " t=" << simTime() << "\n";

    seqNum++;
    emit(pktsSentSignal, 1);
    send(pkt, "out");
}

void TrafficGenerator::scheduleNextSend()
{
    if (profile == "CBR") {
        // Constant Bit Rate: send every sendInterval seconds
        scheduleAt(simTime() + sendInterval, sendTimer);

    } else if (profile == "Bursty") {
        burstCount++;
        if (burstCount < burstSize) {
            // Still in burst: send next packet immediately (0.001s gap)
            scheduleAt(simTime() + 0.001, sendTimer);
        } else {
            // Burst done: wait for burstGap silence period
            burstCount = 0;
            scheduleAt(simTime() + burstGap, sendTimer);
        }
    }
}

void TrafficGenerator::finish()
{
    EV_INFO << "[TrafficGenerator] Total packets sent: " << seqNum << "\n";
}
