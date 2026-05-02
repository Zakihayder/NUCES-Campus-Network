#ifndef TRAFFICGENERATOR_H_
#define TRAFFICGENERATOR_H_

#include <omnetpp.h>
#include <string>
using namespace omnetpp;

class TrafficGenerator : public cSimpleModule
{
  private:
    // Parameters
    std::string profile;
    int    packetSize;
    double sendInterval;
    int    burstSize;
    double burstGap;
    std::string destAddr;
    double startTime;
    double stopTime;

    // Internal state
    int    seqNum;
    int    burstCount;       // how many sent in current burst
    bool   inBurst;

    // Self messages (timers)
    cMessage *sendTimer;

    // Statistics
    simsignal_t pktsSentSignal;

  protected:
    virtual void initialize() override;
    virtual void handleMessage(cMessage *msg) override;
    virtual void finish() override;

    void sendPacket();
    void scheduleNextSend();
};

#endif
