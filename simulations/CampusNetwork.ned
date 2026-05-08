package simulations;

import inet.common.scenario.ScenarioManager;
import inet.node.inet.Router;
import inet.node.inet.StandardHost;
import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import src.StaticRouter;
import src.TrafficGenerator;

network CampusNetwork
{
    parameters:
        @display("bgb=1400,1150;bgc=#ddeeff");

    submodules:

        configurator: Ipv4NetworkConfigurator {
            @display("p=80,1080;i=block/cogwheel;is=s");
        }

        scenarioManager: ScenarioManager {
            @display("p=350,1080;i=block/control;is=s");
        }

        // ================= SE Department =================

        seRouter: Router {
            parameters:
                numEthInterfaces = 10;
            @display("p=280,380;i=device/router;is=m;t=SE-Router [10.0.1.254]");
        }

        seHost1: StandardHost {
            parameters:
                numEthInterfaces = 1;
            @display("p=100,200;i=device/laptop;is=s;t=SE-PC1 10.0.1.1");
        }

        seHost2: StandardHost {
            parameters:
                numEthInterfaces = 1;
            @display("p=280,200;i=device/laptop;is=s;t=SE-PC2 10.0.1.2");
        }

        seHost3: StandardHost {
            parameters:
                numEthInterfaces = 1;
            @display("p=460,200;i=device/laptop;is=s;t=SE-PC3 10.0.1.3");
        }

        tgSE1: TrafficGenerator {
            @display("p=100,60;i=block/source;is=s;t=TG-SE1");
        }

        tgSE2: TrafficGenerator {
            @display("p=280,60;i=block/source;is=s;t=TG-SE2");
        }

        tgSE3: TrafficGenerator {
            @display("p=460,60;i=block/source;is=s;t=TG-SE3");
        }

        // ================= EE Department =================

        eeRouter: Router {
            parameters:
                numEthInterfaces = 10;
            @display("p=1050,380;i=device/router;is=m;t=EE-Router [10.0.2.254]");
        }

        eeHost1: StandardHost {
            parameters:
                numEthInterfaces = 1;
            @display("p=900,200;i=device/laptop;is=s;t=EE-PC1 10.0.2.1");
        }

        eeHost2: StandardHost {
            parameters:
                numEthInterfaces = 1;
            @display("p=1050,200;i=device/laptop;is=s;t=EE-PC2 10.0.2.2");
        }

        eeHost3: StandardHost {
            parameters:
                numEthInterfaces = 1;
            @display("p=1200,200;i=device/laptop;is=s;t=EE-PC3 10.0.2.3");
        }

        // ================= CORE =================

        coreRouter: Router {
            parameters:
                numEthInterfaces = 20;
            @display("p=660,530;i=device/router;is=l;t=Core Router [10.0.0.1]");
        }

        dnsServer: StandardHost {
            parameters:
                numEthInterfaces = 1;
            @display("p=480,530;i=device/server2;is=m;t=DNS 10.0.5.1");
        }

        appServer: StandardHost {
            parameters:
                numEthInterfaces = 1;
            @display("p=840,530;i=device/server2;is=m;t=AppSrv 10.0.6.1");
        }

        // ================= BBA Department =================

        bbaRouter: Router {
            parameters:
                numEthInterfaces = 10;
            @display("p=280,700;i=device/router;is=m;t=BBA-Router [10.0.3.254]");
        }

        bbaHost1: StandardHost {
            parameters:
                numEthInterfaces = 1;
            @display("p=100,880;i=device/laptop;is=s;t=BBA-PC1 10.0.3.1");
        }

        bbaHost2: StandardHost {
            parameters:
                numEthInterfaces = 1;
            @display("p=280,880;i=device/laptop;is=s;t=BBA-PC2 10.0.3.2");
        }

        bbaHost3: StandardHost {
            parameters:
                numEthInterfaces = 1;
            @display("p=460,880;i=device/laptop;is=s;t=BBA-PC3 10.0.3.3");
        }

        // ================= ADMIN =================

        adminRouter: Router {
            parameters:
                numEthInterfaces = 10;
            @display("p=1050,700;i=device/router;is=m;t=Admin-Router [10.0.4.254]");
        }

        adminHost1: StandardHost {
            parameters:
                numEthInterfaces = 1;
            @display("p=900,880;i=device/laptop;is=s;t=Admin-PC1 10.0.4.1");
        }

        adminHost2: StandardHost {
            parameters:
                numEthInterfaces = 1;
            @display("p=1050,880;i=device/laptop;is=s;t=Admin-PC2 10.0.4.2");
        }

        adminHost3: StandardHost {
            parameters:
                numEthInterfaces = 1;
            @display("p=1200,880;i=device/laptop;is=s;t=Admin-PC3 10.0.4.3");
        }

    connections allowunconnected:

        // ================= Backbone =================

        seRouter.ethg++ <--> { datarate=100Mbps; delay=2ms; ber=1e-3; } <--> coreRouter.ethg++;
        eeRouter.ethg++ <--> { datarate=100Mbps; delay=2ms; ber=1e-3; } <--> coreRouter.ethg++;
        bbaRouter.ethg++ <--> { datarate=100Mbps; delay=2ms; ber=1e-3; } <--> coreRouter.ethg++;
        adminRouter.ethg++ <--> { datarate=100Mbps; delay=2ms; ber=1e-3; } <--> coreRouter.ethg++;

        // ================= Servers =================

        coreRouter.ethg++ <--> { datarate=100Mbps; delay=1ms; } <--> dnsServer.ethg++;
        coreRouter.ethg++ <--> { datarate=100Mbps; delay=1ms; } <--> appServer.ethg++;

        // ================= SE Hosts =================

        seRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> seHost1.ethg++;
        seRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> seHost2.ethg++;
        seRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> seHost3.ethg++;

        // ================= EE Hosts =================

        eeRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> eeHost1.ethg++;
        eeRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> eeHost2.ethg++;
        eeRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> eeHost3.ethg++;

        // ================= BBA Hosts =================

        bbaRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> bbaHost1.ethg++;
        bbaRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> bbaHost2.ethg++;
        bbaRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> bbaHost3.ethg++;

        // ================= ADMIN Hosts =================

        adminRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> adminHost1.ethg++;
        adminRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> adminHost2.ethg++;
        adminRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> adminHost3.ethg++;
}