#include "TrafficGenerator.h"

Define_Module(TrafficGenerator);

// ─────────────────────────────────────────────────────────────────
void TrafficGenerator::initialize()
{
    // Read all scenario-specific settings from omnetpp.ini
    profile      = par("trafficProfile").stdstringValue();
    packetSize   = par("packetSize");
    sendInterval = par("sendInterval");
    burstSize    = par("burstSize");
    burstGap     = par("burstGap");
    destAddr     = par("destAddr").stdstringValue();
    srcAddr      = par("srcAddr").stdstringValue();
    startTime = par("startTime").doubleValue();
    stopTime  = par("stopTime").doubleValue();

    seqNum     = 0;
    burstCount = 0;

    // Register OMNeT++ statistics signals
    pktsSentSignal      = registerSignal("pktsSent");
    pktsReceivedSignal  = registerSignal("pktsReceived");
    endToEndDelaySignal = registerSignal("endToEndDelay");

    EV_INFO << "[TG] Init " << getFullPath()
            << "  profile=" << profile
            << "  dest="    << destAddr
            << "  pktSize=" << packetSize << "B"
            << "  start="   << startTime  << "s"
            << "  stop="    << stopTime   << "s\n";

    // Schedule first packet at startTime
    sendTimer = new cMessage("sendTimer");
    scheduleAt(simTime() + startTime, sendTimer);
}

// ─────────────────────────────────────────────────────────────────
void TrafficGenerator::handleMessage(cMessage *msg)
{
    if (msg == sendTimer) {
        // Stop generating once stopTime is reached
        if (simTime() >= stopTime) {
            EV_INFO << "[TG] " << getFullPath()
                    << " reached stopTime=" << stopTime << "s — halting.\n";
            return; // timer not rescheduled
        }
        sendPacket();
        scheduleNextSend();

    } else {
        // Incoming packet — compute end-to-end delay and emit it
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

// ─────────────────────────────────────────────────────────────────
void TrafficGenerator::sendPacket()
{
    cPacket *pkt = new cPacket("TG_DataPacket");
    pkt->setByteLength(packetSize);

    // Attach metadata (used by receiver for delay computation and logging)
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
    send(pkt, "out");
}

// ─────────────────────────────────────────────────────────────────
void TrafficGenerator::scheduleNextSend()
{
    if (profile == "CBR") {
        // Fixed inter-arrival interval
        scheduleAt(simTime() + sendInterval, sendTimer);

    } else if (profile == "Bursty") {
        burstCount++;
        if (burstCount < burstSize) {
            // Still within a burst — back-to-back with 1 ms spacing
            scheduleAt(simTime() + 0.001, sendTimer);
        } else {
            // Burst done — wait for the silence gap, then repeat
            burstCount = 0;
            scheduleAt(simTime() + burstGap, sendTimer);
        }
    } else {
        EV_WARN << "[TG] Unknown profile '" << profile
                << "' — defaulting to CBR\n";
        scheduleAt(simTime() + sendInterval, sendTimer);
    }
}

// ─────────────────────────────────────────────────────────────────
void TrafficGenerator::finish()
{
    EV_INFO << "[TG] === SUMMARY " << getFullPath() << " ===\n"
            << "  Packets sent : " << seqNum    << "\n"
            << "  Profile      : " << profile   << "\n"
            << "  Destination  : " << destAddr  << "\n";
    recordScalar("totalPacketsSent", seqNum);
}