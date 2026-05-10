package src;
simple StaticRouter
{
    parameters:
        int numPorts = default(4);
        string routeTable = default("");

        @signal[pktsForwarded](type=long);
        @signal[pktsDropped](type=long);

        // Define port-specific signals for the core router
       	@signal[linkUtilPort0](type=long);
        @signal[linkUtilPort1](type=long);
        @signal[linkUtilPort2](type=long);
        @signal[linkUtilPort3](type=long);

        @statistic[linkUtilPort0](title="Port 0 Bytes"; source=linkUtilPort0; record=vector,sum; interpolationmode=none);
        @statistic[linkUtilPort1](title="Port 1 Bytes"; source=linkUtilPort1; record=vector,sum; interpolationmode=none);

        @statistic[linkUtilPort2](title="Link 2 Utilization"; source=linkUtilPort2; record=vector,sum);
        @statistic[linkUtilPort3](title="Link 3 Utilization"; source=linkUtilPort3; record=vector,sum);

        @display("i=device/router");
    gates:
        inout port[numPorts];
}
