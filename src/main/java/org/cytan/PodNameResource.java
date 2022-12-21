package org.cytan;

import java.net.InetAddress;
import java.net.UnknownHostException;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.eclipse.microprofile.config.inject.ConfigProperty;

@Path("/")
public class PodNameResource {

    @GET
    @Path("/")
    @Produces(MediaType.TEXT_PLAIN)
    public String getPodName() throws UnknownHostException{
        return "Hello Customer! from " + InetAddress.getLocalHost().getHostName();
    }







    @ConfigProperty(name = "greeting.message", defaultValue = "default coding")
    String message;

    @GET
    @Path("/greeting")
    @Produces(MediaType.TEXT_PLAIN)
    public String greet() {
        return "Greeting from "+this.message;
    }

    @GET
    @Path("/hello-resteasy")
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        return "Hello RESTEasy";
    }

}
