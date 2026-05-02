package src;

simple StaticRouter
{
    parameters:
        int    numPorts   = default(0);
        string routeTable = default("");
        string ipAddress = default("0.0.0.0");

        @signal[pktsForwarded](type=long);
        @signal[pktsDropped](type=long);
        @signal[linkUtilization](type=double);

        @statistic[pktsForwarded](
            title="Packets Forwarded";
            source=pktsForwarded;
            record=count,sum;
            interpolationmode=none);

        @statistic[pktsDropped](
            title="Packets Dropped";
            source=pktsDropped;
            record=count,sum;
            interpolationmode=none);

        @statistic[linkUtilization](
            title="Link Utilization %";
            source=linkUtilization;
            record=vector,mean;
            interpolationmode=linear);

        @display("i=device/router");

    gates:
        inout port[numPorts] @loose;
}