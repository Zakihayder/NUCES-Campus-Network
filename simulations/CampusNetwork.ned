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

        // ─── SE Department ──────────────────────────────────────
        seRouter: Router {
            @display("p=280,380;i=device/router;is=m;t=SE-Router");
        }
        seHost1: StandardHost { @display("p=100,200;i=device/laptop;is=s;t=SE-PC1"); }
        seHost2: StandardHost { @display("p=280,200;i=device/laptop;is=s;t=SE-PC2"); }
        seHost3: StandardHost { @display("p=460,200;i=device/laptop;is=s;t=SE-PC3"); }

        // Traffic Generators on SE subnet
        tgSE1: TrafficGenerator { @display("p=100,60;i=block/source;is=s;t=TG-SE1"); }
        tgSE2: TrafficGenerator { @display("p=280,60;i=block/source;is=s;t=TG-SE2"); }
        tgSE3: TrafficGenerator { @display("p=460,60;i=block/source;is=s;t=TG-SE3"); }

        // ─── EE Department ──────────────────────────────────────
        eeRouter: Router {
            @display("p=1050,380;i=device/router;is=m;t=EE-Router");
        }
        eeHost1: StandardHost { @display("p=900,200;i=device/laptop;is=s;t=EE-PC1"); }
        eeHost2: StandardHost { @display("p=1050,200;i=device/laptop;is=s;t=EE-PC2"); }
        eeHost3: StandardHost { @display("p=1200,200;i=device/laptop;is=s;t=EE-PC3"); }

        // ─── Data Center ────────────────────────────────────────
        coreRouter: Router {
            @display("p=660,530;i=device/router;is=l;t=Core-Router");
        }
        dnsServer: StandardHost { @display("p=480,530;i=device/server2;is=m;t=DNS-Server"); }
        appServer: StandardHost { @display("p=840,530;i=device/server2;is=m;t=App-Server"); }

        // ─── BBA Department ─────────────────────────────────────
        bbaRouter: Router {
            @display("p=280,700;i=device/router;is=m;t=BBA-Router");
        }
        bbaHost1: StandardHost { @display("p=100,880;i=device/laptop;is=s;t=BBA-PC1"); }
        bbaHost2: StandardHost { @display("p=280,880;i=device/laptop;is=s;t=BBA-PC2"); }
        bbaHost3: StandardHost { @display("p=460,880;i=device/laptop;is=s;t=BBA-PC3"); }

        // ─── Admin Department ───────────────────────────────────
        adminRouter: Router {
            @display("p=1050,700;i=device/router;is=m;t=Admin-Router");
        }
        adminHost1: StandardHost { @display("p=900,880;i=device/laptop;is=s;t=Admin-PC1"); }
        adminHost2: StandardHost { @display("p=1050,880;i=device/laptop;is=s;t=Admin-PC2"); }
        adminHost3: StandardHost { @display("p=1200,880;i=device/laptop;is=s;t=Admin-PC3"); }

    connections:

        // ── Backbone Links: 100 Mbps, 2 ms, 0.1% BER ─────────────────
        seRouter.ethg++    <--> { datarate=100Mbps; delay=2ms; ber=1e-3; } <--> coreRouter.ethg++;
        eeRouter.ethg++    <--> { datarate=100Mbps; delay=2ms; ber=1e-3; } <--> coreRouter.ethg++;
        bbaRouter.ethg++   <--> { datarate=100Mbps; delay=2ms; ber=1e-3; } <--> coreRouter.ethg++;
        adminRouter.ethg++ <--> { datarate=100Mbps; delay=2ms; ber=1e-3; } <--> coreRouter.ethg++;

        // ── Server Links: 100 Mbps, 1 ms ──────────────────────────────
        coreRouter.ethg++ <--> { datarate=100Mbps; delay=1ms; } <--> dnsServer.ethg++;
        coreRouter.ethg++ <--> { datarate=100Mbps; delay=1ms; } <--> appServer.ethg++;

        // ── SE Access Links: 10 Mbps, 1 ms ────────────────────────────
        seRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> seHost1.ethg++;
        seRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> seHost2.ethg++;
        seRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> seHost3.ethg++;

        // ── TG Links: same access link params, ethg <--> ethg++ ───────
        // KEY FIX: use <--> with TG's ethg gate (inout) matching seRouter.ethg++ (inout)
        tgSE1.ethg <--> { datarate=10Mbps; delay=1ms; } <--> seRouter.ethg++;
        tgSE2.ethg <--> { datarate=10Mbps; delay=1ms; } <--> seRouter.ethg++;
        tgSE3.ethg <--> { datarate=10Mbps; delay=1ms; } <--> seRouter.ethg++;

        // ── EE Access Links ────────────────────────────────────────────
        eeRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> eeHost1.ethg++;
        eeRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> eeHost2.ethg++;
        eeRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> eeHost3.ethg++;

        // ── BBA Access Links ───────────────────────────────────────────
        bbaRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> bbaHost1.ethg++;
        bbaRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> bbaHost2.ethg++;
        bbaRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> bbaHost3.ethg++;

        // ── Admin Access Links ─────────────────────────────────────────
        adminRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> adminHost1.ethg++;
        adminRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> adminHost2.ethg++;
        adminRouter.ethg++ <--> { datarate=10Mbps; delay=1ms; } <--> adminHost3.ethg++;
}
