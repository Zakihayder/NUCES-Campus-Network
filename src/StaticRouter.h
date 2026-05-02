#ifndef STATICROUTER_H_
#define STATICROUTER_H_

#include <omnetpp.h>
#include <vector>
#include <string>
#include <sstream>

using namespace omnetpp;

// One forwarding table entry
struct RouteEntry {
    uint32_t destNetwork;
    uint32_t subnetMask;
    int      outPort;
};

class StaticRouter : public cSimpleModule
{
  private:
    std::vector<RouteEntry> routeTable;

    // Statistics signals
    simsignal_t pktsForwardedSignal;
    simsignal_t pktsDroppedSignal;
    simsignal_t linkUtilSignal;

    // Internal counters
    int totalForwarded;
    int totalDropped;
    bool linkDown;

    // Helper functions
    uint32_t ipToInt(const std::string& ip);
    int      lookupRoute(uint32_t destIP);
    std::string intToIp(uint32_t ip);

  protected:
    virtual void initialize() override;
    virtual void handleMessage(cMessage *msg) override;
    virtual void finish() override;
};

#endif
