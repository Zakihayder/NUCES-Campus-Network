package src;

simple TrafficGenerator
{
    parameters:
        string trafficProfile = default("CBR");  // "CBR" or "Bursty"
        int    packetSize     = default(512);     // bytes
        double sendInterval   = default(0.01);    // seconds (CBR)
        int    burstSize      = default(10);      // packets per burst
        double burstGap       = default(0.5);     // silence gap in seconds
        string destAddr       = default("10.0.6.2"); // app server IP
        double startTime      = default(20.0);    // when to start sending
        double stopTime       = default(155.0);   // when to stop

        @display("i=block/source");

    gates:
        output out;
}