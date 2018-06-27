using System.IO;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using System.Security.Authentication;
using Microsoft.AspNetCore.Server.Kestrel.Https;
using System.Security.Cryptography.X509Certificates;

namespace ServiceA
{
    public class Program
    {
        private static X509Chain serverChain;

        public static IConfiguration Configuration { get; set; }

        /// <summary>
        /// Console entry point
        /// </summary>
        /// <param name="args">command arguments</param>
        public static void Main(string[] args)
        {
            var builder = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json");

            Configuration = builder.Build();
            BuildWebHost(args).Run();
        }

        public static IWebHost BuildWebHost(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>()
                .UseKestrel((context, options) =>
                    {
                        options.Configure(Configuration.GetSection("Kestrel"))
                            .Endpoint("HTTPS", opt =>
                            {

                                opt.HttpsOptions.SslProtocols = SslProtocols.Tls12;

                                serverChain = new X509Chain();
                                serverChain.Build(opt.HttpsOptions.ServerCertificate);

                                opt.HttpsOptions.ClientCertificateMode = ClientCertificateMode.RequireCertificate;
                                opt.HttpsOptions.ClientCertificateValidation = (certificate2, chain, policyErrors) =>
                                {
                                    return chain.ChainElements[1].Certificate.GetCertHashString().Equals(serverChain.ChainElements[1].Certificate.GetCertHashString());
                                };
                            });
                    })
                .Build();       
    }
}
