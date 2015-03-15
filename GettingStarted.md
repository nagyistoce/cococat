# Getting Started #

## Configuration on OS X ##
  1. Create an ajp.conf file in **/private/etc/apache2/other/**
  1. Open ajp.conf file and past the following lines
```
ProxyRequests Off
<Proxy *>
        Order deny,allow
        Deny from all
        Allow from localhost
</Proxy>
ProxyPass 		/cococat/ ajp://localhost:8009/
ProxyPassReverse 	/cococat/ ajp://localhost:8009/
```
  1. restart the apache process
```
sudo httpd -k restart
```

> ## Building for OS X ##
    1. Get the latest source with **hg clone https://cococat.googlecode.com/hg/ cococat**
    1. Open  the project file **CocoCatKit.xcodeproj** in XCode
    1. Select the target **CocoCatKit (MacOS x86\_64)** and build it
    1. Open  the project file **example/HelloWorld/HelloWorld.xcodeproj** in XCode
    1. Select the target **HelloWorld (MacOS x86\_64)** and build it

> ## Testing ##
The HelloWorld example will start an ajp13 and a http server
    1. Start the HelloWorld example
    1. Open http://localhost/cococat/ in safari (ajp13 connection)
    1. Open http://localhost:8010/ in safari (http connection)