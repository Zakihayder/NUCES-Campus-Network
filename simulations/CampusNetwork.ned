package simulations;

import inet.common.scenario.ScenarioManager;
import inet.node.inet.Router;
import inet.node.inet.StandardHost;
import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import src.StaticRouter;

network CampusNetwork
{
    parameters:
        @display("bgb=1200,1000;bgc=#ddeeff");

    submodules:

        // ── Configurator (hidden bottom corner) ────────────────
        configurator: Ipv4NetworkConfigurator {
            @display("p=80,950;i=block/cogwheel;is=s");
        }
		

        // ── Scenario Manager (controls link failure) ───────────
        scenarioManager: ScenarioManager {
            @display("p=200,950;i=block/control;is=s");
        }


        // ══════════════════════════════════════════════════════
        // SE DEPARTMENT — Top Left Building
        // ══════════════════════════════════════════════════════
        seRouter: Router {
            @display("p=250,350;i=device/router;is=m;t=SE-Router\n[10.0.1.254];bgb=200,180;bgt=SE Dept;bgc=#cce5ff");
        }
        seHost1: StandardHost {
            @display("p=120,200;i=device/laptop;is=s;t=SE-PC1\n10.0.1.1");
        }
        seHost2: StandardHost {
            @display("p=250,200;i=device/laptop;is=s;t=SE-PC2\n10.0.1.2");
        }
        seHost3: StandardHost {
            @display("p=380,200;i=device/laptop;is=s;t=SE-PC3\n10.0.1.3");
        }

        // ══════════════════════════════════════════════════════
        // EE DEPARTMENT — Top Right Building
        // ══════════════════════════════════════════════════════
        eeRouter: Router {
            @display("p=950,350;i=device/router;is=m;t=EE-Router\n[10.0.2.254]");
        }
        eeHost1: StandardHost {
            @display("p=820,200;i=device/laptop;is=s;t=EE-PC1\n10.0.2.1");
        }
        eeHost2: StandardHost {
            @display("p=950,200;i=device/laptop;is=s;t=EE-PC2\n10.0.2.2");
        }
        eeHost3: StandardHost {
            @display("p=1080,200;i=device/laptop;is=s;t=EE-PC3\n10.0.2.3");
        }

        // ══════════════════════════════════════════════════════
        // DATA CENTER — Center
        // ══════════════════════════════════════════════════════
        coreRouter: Router {
            @display("p=600,500;i=device/router;is=l;t=Core Router\n[10.0.0.1]");
        }
        dnsServer: StandardHost {
            @display("p=430,500;i=device/server2;is=m;t=DNS Server\n10.0.5.1");
        }
        appServer: StandardHost {
            @display("p=770,500;i=device/server2;is=m;t=App Server\n10.0.6.1");
        }

        // ══════════════════════════════════════════════════════
        // BBA DEPARTMENT — Bottom Left Building
        // ══════════════════════════════════════════════════════
        bbaRouter: Router {
            @display("p=250,650;i=device/router;is=m;t=BBA-Router\n[10.0.3.254]");
        }
        bbaHost1: StandardHost {
            @display("p=120,800;i=device/laptop;is=s;t=BBA-PC1\n10.0.3.1");
        }
        bbaHost2: StandardHost {
            @display("p=250,800;i=device/laptop;is=s;t=BBA-PC2\n10.0.3.2");
        }
        bbaHost3: StandardHost {
            @display("p=380,800;i=device/laptop;is=s;t=BBA-PC3\n10.0.3.3");
        }

        // ══════════════════════════════════════════════════════
        // ADMIN DEPARTMENT — Bottom Right Building
        // ══════════════════════════════════════════════════════
        adminRouter: Router {
            @display("p=950,650;i=device/router;is=m;t=Admin-Router\n[10.0.4.254]");
        }
        adminHost1: StandardHost {
            @display("p=820,800;i=device/laptop;is=s;t=Admin-PC1\n10.0.4.1");
        }
        adminHost2: StandardHost {
            @display("p=950,800;i=device/laptop;is=s;t=Admin-PC2\n10.0.4.2");
        }
        adminHost3: StandardHost {
            @display("p=1080,800;i=device/laptop;is=s;t=Admin-PC3\n10.0.4.3");
        }

    connections:

        // ── Backbone: 100Mbps, 2ms, 0.1% BER ─────────────────
        seRouter.ethg++    <--> {datarate=100Mbps; delay=2ms; ber=1e-3; @display("ls=#e74c3c,3");} <--> coreRouter.ethg++;
        eeRouter.ethg++    <--> {datarate=100Mbps; delay=2ms; ber=1e-3; @display("ls=#e74c3c,3");} <--> coreRouter.ethg++;
        bbaRouter.ethg++   <--> {datarate=100Mbps; delay=2ms; ber=1e-3; @display("ls=#e74c3c,3");} <--> coreRouter.ethg++;
        adminRouter.ethg++ <--> {datarate=100Mbps; delay=2ms; ber=1e-3; @display("ls=#e74c3c,3");} <--> coreRouter.ethg++;

        // ── Server Links: 100Mbps, 1ms ─────────────────────────
        coreRouter.ethg++ <--> {datarate=100Mbps; delay=1ms; @display("ls=#8e44ad,2");} <--> dnsServer.ethg++;
        coreRouter.ethg++ <--> {datarate=100Mbps; delay=1ms; @display("ls=#8e44ad,2");} <--> appServer.ethg++;

        // ── SE Access: 10Mbps, 1ms ────────────────────────────
        seRouter.ethg++ <--> {datarate=10Mbps; delay=1ms; @display("ls=#27ae60,1");} <--> seHost1.ethg++;
        seRouter.ethg++ <--> {datarate=10Mbps; delay=1ms; @display("ls=#27ae60,1");} <--> seHost2.ethg++;
        seRouter.ethg++ <--> {datarate=10Mbps; delay=1ms; @display("ls=#27ae60,1");} <--> seHost3.ethg++;

        // ── EE Access: 10Mbps, 1ms ────────────────────────────
        eeRouter.ethg++ <--> {datarate=10Mbps; delay=1ms; @display("ls=#27ae60,1");} <--> eeHost1.ethg++;
        eeRouter.ethg++ <--> {datarate=10Mbps; delay=1ms; @display("ls=#27ae60,1");} <--> eeHost2.ethg++;
        eeRouter.ethg++ <--> {datarate=10Mbps; delay=1ms; @display("ls=#27ae60,1");} <--> eeHost3.ethg++;

        // ── BBA Access: 10Mbps, 1ms ───────────────────────────
        bbaRouter.ethg++ <--> {datarate=10Mbps; delay=1ms; @display("ls=#27ae60,1");} <--> bbaHost1.ethg++;
        bbaRouter.ethg++ <--> {datarate=10Mbps; delay=1ms; @display("ls=#27ae60,1");} <--> bbaHost2.ethg++;
        bbaRouter.ethg++ <--> {datarate=10Mbps; delay=1ms; @display("ls=#27ae60,1");} <--> bbaHost3.ethg++;

        // ── Admin Access: 10Mbps, 1ms ─────────────────────────
        adminRouter.ethg++ <--> {datarate=10Mbps; delay=1ms; @display("ls=#27ae60,1");} <--> adminHost1.ethg++;
        adminRouter.ethg++ <--> {datarate=10Mbps; delay=1ms; @display("ls=#27ae60,1");} <--> adminHost2.ethg++;
        adminRouter.ethg++ <--> {datarate=10Mbps; delay=1ms; @display("ls=#27ae60,1");} <--> adminHost3.ethg++;
}