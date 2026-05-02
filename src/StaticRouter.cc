#include "StaticRouter.h"

Define_Module(StaticRouter);

// ── IP string to uint32 ──────────────────────────────────────────────
uint32_t StaticRouter::ipToInt(const std::string& ip)
{
    uint32_t result = 0;
    std::istringstream ss(ip);
    std::string octet;
    int shift = 24;
    while (std::getline(ss, octet, '.') && shift >= 0) {
        result |= ((uint32_t)std::stoi(octet) << shift);
        shift -= 8;
    }
    return result;
}

// ── uint32 to IP string ──────────────────────────────────────────────
std::string StaticRouter::intToIp(uint32_t ip)
{
    return std::to_string((ip >> 24) & 0xFF) + "." +
           std::to_string((ip >> 16) & 0xFF) + "." +
           std::to_string((ip >>  8) & 0xFF) + "." +
           std::to_string( ip        & 0xFF);
}

// ── Longest Prefix Match ─────────────────────────────────────────────
int StaticRouter::lookupRoute(uint32_t destIP)
{
    int      bestPort = -1;
    uint32_t bestMask =  0;

    for (const auto& entry : routeTable) {
        if ((destIP & entry.subnetMask) == entry.destNetwork) {
            if (entry.subnetMask >= bestMask) {
                bestMask = entry.subnetMask;
                bestPort = entry.outPort;
            }
        }
    }
    return bestPort;
}

// ── initialize() ────────────────────────────────────────────────────
void StaticRouter::initialize()
{
    // Register signals
    pktsForwardedSignal = registerSignal("pktsForwarded");
    pktsDroppedSignal   = registerSignal("pktsDropped");
    linkUtilSignal      = registerSignal("linkUtilization");

    totalForwarded = 0;
    totalDropped   = 0;
    linkDown       = false;

    // Parse route table from ini parameter
    // Format: "destNet/mask:port;destNet/mask:port;..."
    std::string tableStr = par("routeTable").stdstringValue();

    if (tableStr.empty()) {
        EV_WARN << "[StaticRouter:" << getFullName()
                << "] WARNING: No route table configured!\n";
        return;
    }

    std::istringstream ss(tableStr);
    std::string entry;
    while (std::getline(ss, entry, ';')) {
        if (entry.empty()) continue;

        auto colonPos = entry.find(':');
        if (colonPos == std::string::npos) continue;

        std::string netPart = entry.substr(0, colonPos);
        int port = std::stoi(entry.substr(colonPos + 1));

        auto slashPos = netPart.find('/');
        if (slashPos == std::string::npos) continue;

        std::string dest = netPart.substr(0, slashPos);
        std::string mask = netPart.substr(slashPos + 1);

        RouteEntry re;
        re.destNetwork = ipToInt(dest);
        re.subnetMask  = ipToInt(mask);
        re.outPort     = port;
        routeTable.push_back(re);

        EV_INFO << "[StaticRouter:" << getFullName()
                << "] Route loaded: " << dest
                << "/" << mask
                << " -> port " << port << "\n";
    }

    EV_INFO << "[StaticRouter:" << getFullName()
            << "] Initialized with " << routeTable.size()
            << " route entries.\n";

    // Schedule periodic link utilization reporting every 10s
    scheduleAt(simTime() + 10.0, new cMessage("utilTimer"));
}

// ── handleMessage() ──────────────────────────────────────────────────
void StaticRouter::handleMessage(cMessage *msg)
{
    // Handle our own timer
    if (msg->isSelfMessage()) {
        // Emit link utilization signal
        double util = (totalForwarded > 0) ?
            (double)totalForwarded / (totalForwarded + totalDropped) * 100.0 : 0.0;
        emit(linkUtilSignal, util);
        EV_INFO << "[StaticRouter:" << getFullName()
                << "] Link utilization snapshot: " << util << "%\n";
        scheduleAt(simTime() + 10.0, msg);
        return;
    }

    // Get destination from packet parameter
    if (!msg->hasPar("destAddr")) {
        // Not our packet format — forward to port 0 by default
        EV_WARN << "[StaticRouter:" << getFullName()
                << "] Packet has no destAddr param, forwarding to port 0\n";
        if (gateSize("port") > 0)
            send(msg, "port$o", 0);
        else
            delete msg;
        return;
    }

    std::string destStr = msg->par("destAddr").stringValue();
    std::string srcStr  = msg->hasPar("srcAddr") ?
                          msg->par("srcAddr").stringValue() : "unknown";
    uint32_t destIP = ipToInt(destStr);

    int port = lookupRoute(destIP);

    if (port == -1 || linkDown) {
        // No route found OR link is down — DROP
        EV_WARN << "[StaticRouter:" << getFullName()
                << "] DROP pkt: src=" << srcStr
                << " dst=" << destStr
                << " reason=" << (linkDown ? "LINK_DOWN" : "NO_ROUTE")
                << " t=" << simTime() << "\n";
        emit(pktsDroppedSignal, 1);
        totalDropped++;
        delete msg;
    } else {
        // Forward
        EV_INFO << "[StaticRouter:" << getFullName()
                << "] FORWARD pkt: dst=" << destStr
                << " -> port " << port
                << " t=" << simTime() << "\n";
        emit(pktsForwardedSignal, 1);
        totalForwarded++;
        send(msg, "port$o", port);
    }
}

// ── finish() ─────────────────────────────────────────────────────────
void StaticRouter::finish()
{
    EV_INFO << "\n[StaticRouter:" << getFullName() << "] === FINAL STATISTICS ===\n"
            << "  Total Forwarded : " << totalForwarded << "\n"
            << "  Total Dropped   : " << totalDropped   << "\n"
            << "  Drop Reason     : No route / Link down\n"
            << "  Routing Overhead: 0 control messages\n";

    recordScalar("totalForwarded", totalForwarded);
    recordScalar("totalDropped",   totalDropped);
    recordScalar("routingOverhead", 0);
}
