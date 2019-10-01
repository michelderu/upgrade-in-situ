FROM centos:centos7
# Get any CentOS updates then clear the Docker cache
RUN yum -y update && yum clean all
# Install MarkLogic dependencies
RUN yum -y install glibc.i686 gdb.x86_64 redhat-lsb.x86_64 && yum clean all
RUN yum -y install cyrus-sasl-lib libgcc libstdc++ libstdc++.i686 && yum clean all
RUN yum -y install sudo && yum clean all
# Install the initscripts package so MarkLogic starts ok
RUN yum -y install initscripts && yum clean all
# Set the Path
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/MarkLogic/mlcmd/bin
# Copy the MarkLogic installer to a temp directory in the Docker image being built
COPY MarkLogic-8.0-4.2.x86_64.rpm /tmp/MarkLogic.rpm
#COPY MarkLogicConverters-9.0-8.x86_64.rpm /tmp/MarkLogicConverters.rpm
# Install MarkLogic then delete the .RPM file if the install succeeded
RUN yum -y install /tmp/MarkLogic.rpm && rm /tmp/MarkLogic.rpm
#RUN yum -y install /tmp/MarkLogicConverters.rpm && rm /tmp/MarkLogicConverters.rpm
# Create symlinks
RUN ln -sf /lib64/libsasl2.so.3.0.0 /lib64/libsasl2.so.2
RUN ln -sf /lib64/libpython2.7.so.1.0 /lib64/libpython2.6.so.1.0
# Expose MarkLogic Server ports
# Also expose any ports your own MarkLogic App Servers use such as
# HTTP, REST and XDBC App Servers for your applications
#
# HealthCheck application server port
EXPOSE 7997
# Foreign inter-host communication between MarkLogic clusters
EXPOSE 7998
# Inter-host communication within the cluster
EXPOSE 7999
# App-Services application server port and is required by Query Console
EXPOSE 8000
# Admin application server port and is required by the Administrative Interface
EXPOSE 8001
# Manage application server port and is required by Configuration Manager and Monitoring Dashboard
EXPOSE 8002
# Start MarkLogic from init.d script.
# Define default command (which avoids immediate shutdown)
CMD /etc/init.d/MarkLogic start && tail -f /dev/null
#
# With the above, build the image using:
# docker build -t marklogic:8.0-4.2 .
#
