SDKVER=6.1
PLATFORM=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform
SDK=$(PLATFORM)/Developer/SDKs/iPhoneOS$(SDKVER).sdk
LD=$(PLATFORM)/Developer/usr/bin/ld
AS=$(PLATFORM)/Developer/usr/bin/as
CC=clang -arch $(ARCH)
ARCH=armv7

LDFLAGS= -L$(SDK)/usr/lib -L$(SDK)/usr/lib/system -L/opt/iOSOpenDev/lib/  -dynamiclib -lsubstrate -framework Foundation 
CFLAGS= -O3 -arch $(ARCH) -mthumb -isysroot=$(SDK)  -I$(SDK)/usr/include -I/opt/iOSOpenDev/include -F$(SDK)/System/Library/Frameworks
CFLAGSFULL= $(CFLAGS) $(LDFLAGS) 

IPHONEIP=127.0.0.1
SSHPORT=2222

INSTALLFOLDER=/Library/MobileSubstrate/DynamicLibraries/
LIBNAME=StealthJB
SRCEXT=m
OUTPUT=build
PACKAGE=org.gotohack.stealthjb

all: $(LIBNAME)

$(LIBNAME): $(LIBNAME).$(SRCEXT)
	@mkdir -p $(OUTPUT)
	$(CC) $(CFLAGSFULL) -o $(OUTPUT)/$@.dylib $^
	ldid -S $(OUTPUT)/$@.dylib

dist: $(LIBNAME)
	@rm -rf $(OUTPUT)/$(PACKAGE)/Library/MobileSubstrate/DynamicLibraries/
	@mkdir -p  $(OUTPUT)/$(PACKAGE)/DEBIAN
	@cp -v control  $(OUTPUT)/$(PACKAGE)/DEBIAN/
	@mkdir -p  $(OUTPUT)/$(PACKAGE)/Library/MobileSubstrate/DynamicLibraries/
	@cp $(OUTPUT)/$(LIBNAME).dylib $(OUTPUT)/$(PACKAGE)/Library/MobileSubstrate/DynamicLibraries/
	dpkg -b $(OUTPUT)/$(PACKAGE)

respring:
	ssh -p $(SSHPORT) mobile@$(IPHONEIP) 'killall -9 SpringBoard'

config:
	@echo "Binary file to hook (JBChecker):"
	@echo "{"                >  $(OUTPUT)/$(PACKAGE).plist
	@echo "Filter = {"       >> $(OUTPUT)/$(PACKAGE).plist
	@echo "	Executables = (" >> $(OUTPUT)/$(PACKAGE).plist
	@read execfiles; echo $$execfiles","  >> $(OUTPUT)/$(PACKAGE).plist
	@echo "	);"              >> $(OUTPUT)/$(PACKAGE).plist
	@echo "		};"          >> $(OUTPUT)/$(PACKAGE).plist
	@echo "}"                >> $(OUTPUT)/$(PACKAGE).plist

installconfig:
	scp -P $(SSHPORT) $(OUTPUT)/$(PACKAGE).plist root@$(IPHONEIP):$(INSTALLFOLDER)/

removeconfig:
	ssh -p $(SSHPORT) root@$(IPHONEIP) 'rm -f $(INSTALLFOLDER)/$(LIBNAME).plist'

dpkgi: dist
	scp -P $(SSHPORT) $(OUTPUT)/$(PACKAGE).deb root@$(IPHONEIP):~/
	ssh -p $(SSHPORT) root@$(IPHONEIP) 'dpkg -i ~/$(PACKAGE).deb'

dpkgr:
	ssh -p $(SSHPORT) root@$(IPHONEIP) 'dpkg -r $(PACKAGE)'

install:
	ssh -p $(SSHPORT) root@$(IPHONEIP) 'rm -fr $(INSTALLFOLDER)/$(LIBNAME).dylib'
	scp -P $(SSHPORT) $(OUTPUT)/$(LIBNAME){.plist,.dylib} root@$(IPHONEIP):$(INSTALLFOLDER)/
	@echo "$(OUTPUT)/$(LIBNAME).dylib installed in $(INSTALLFOLDER)"
	@echo "$(OUTPUT)/$(LIBNAME).plist installed in $(INSTALLFOLDER)"
	
uninstall:
	ssh -p $(SSHPORT) root@$(IPHONEIP) 'rm -fr $(INSTALLFOLDER)/$(LIBNAME).dylib'
	ssh -p $(SSHPORT) root@$(IPHONEIP) 'rm -fr $(INSTALLFOLDER)/$(LIBNAME).dylib'
	@echo "$(INSTALLFOLDER)/$(LIBNAME).dylib uninstalled"

clean:
	-rm -f $(OUTPUT)/*.o
	-rm -f $(OUTPUT)/*.dylib
	-rm -rf $(OUTPUT)/$(PACKAGE)

.PHONY:	all clean dist


