package src;

simple StaticRouter
{
    parameters:
        int    numPorts   = default(10); // Matches the '10' used in your CampusNetwork
        string routeTable = default("");
        string ipAddress  = default("0.0.0.0");

        @signal[pktsForwarded](type=long);
        @signal[pktsDropped](type=long);
        @signal[linkUtilization](type=double);

        @statistic[pktsForwarded](title="Packets Forwarded"; source=pktsForwarded; record=count,sum; interpolationmode=none);
        @statistic[pktsDropped](title="Packets Dropped"; source=pktsDropped; record=count,sum; interpolationmode=none);
        @statistic[linkUtilization](title="Link Utilization %"; source=linkUtilization; record=vector,mean; interpolationmode=linear);

        @display("i=device/router");

    gates:
        // CHANGED: 'port' renamed to 'ethg' to match your CampusNetwork connections
        inout ethg[numPorts] @loose;
}