#ifndef TRAFFICGENERATOR_H_
#define TRAFFICGENERATOR_H_

#include <omnetpp.h>
#include <string>
using namespace omnetpp;

class TrafficGenerator : public cSimpleModule
{
  private:
    // ── Parameters (read from omnetpp.ini) ──────────────────────
    std::string profile;       // "CBR" or "Bursty"
    int         packetSize;    // bytes
    double      sendInterval;  // CBR inter-arrival (s)
    int         burstSize;     // packets per burst
    double      burstGap;      // silence gap between bursts (s)
    std::string destAddr;      // destination IP string
    std::string srcAddr;       // source IP string
    double      startTime;     // when to start (s)
    double      stopTime;      // when to stop  (s)

    // ── Internal state ──────────────────────────────────────────
    int  seqNum;
    int  burstCount;
    cMessage *sendTimer;

    // ── OMNeT++ signals for result recording ────────────────────
    simsignal_t pktsSentSignal;
    simsignal_t pktsReceivedSignal;
    simsignal_t endToEndDelaySignal;

  protected:
    virtual void initialize() override;
    virtual void handleMessage(cMessage *msg) override;
    virtual void finish() override;

  private:
    void sendPacket();
    void scheduleNextSend();
};

#endif