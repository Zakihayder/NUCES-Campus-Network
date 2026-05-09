package src;

//
// Custom Traffic Generator — sends CBR or Bursty traffic toward the app server.
// Uses an inout gate so it can connect to standard router ethg++ ports
// with the normal <--> bidirectional channel syntax.
//
simple TrafficGenerator
{
    parameters:
         string trafficProfile = default("CBR");     // "CBR" or "Bursty"
        int packetSize @unit(B) = default(512B);        // packet payload in bytes
        double sendInterval @unit(s)   = default(0.01s);       // CBR: time between packets (s)
        int    burstSize      = default(10);         // Bursty: packets per burst
        double burstGap @unit(s)       = default(0.5s);        // Bursty: silence gap between bursts (s)
        string destAddr       = default("10.0.6.1"); // application server IP
        string srcAddr        = default("10.0.1.1"); // source IP (set per-host in ini)
        volatile double startTime @unit(s) = default(20s);
	volatile double stopTime  @unit(s) = default(155s);
	
	
        @signal[pktsSent](type=long);
        @signal[pktsReceived](type=long);
        @signal[endToEndDelay](type=double);

        @statistic[pktsSent](
            title="Packets Sent";
            source=pktsSent;
            record=count,sum;
            interpolationmode=none);

        @statistic[pktsReceived](
            title="Packets Received";
            source=pktsReceived;
            record=count,sum;
            interpolationmode=none);

        @statistic[endToEndDelay](
            title="End-to-End Delay (s)";
            source=endToEndDelay;
            record=vector,mean,max,percentile(95);
            interpolationmode=none);

        @display("i=block/source");

    gates:
        inout ethg;   // bidirectional — matches seRouter.ethg++ connection style
}