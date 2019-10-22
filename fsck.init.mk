fsck:
	echo "MRC:$@> Checking disks." ;\
	fsck -p ;\
	case $$? in \
	0) ;; \
	2) exit 1 \
	   ;; \
	4) echo "Rebooting..." ;\
	   reboot ;\
	   echo "Reboot failed; help!" ;\
	   exit 1 \
	   ;; \
	8) if [ -n "$${FSCK_Y_ENABLE}" ]; then \
	     echo "File system preen failed, trying fsck -y." ;\
	     fsck -y || {\
	       echo "Automatic file system check failed; help!" ;\
	       exit 1 ;\
	     }\
	   else \
	     echo "Automatic file system check failed; help!" ;\
	     exit 1 ;\
	   fi ;\
	   ;; \
	12) echo "Boot interrupted." ;\
	   exit 1 \
	   ;; \
	130) exit 1 \
	   ;; \
	*) echo "Unknown error, help!" ;\
	   exit 1 \
	   ;; \
	esac
