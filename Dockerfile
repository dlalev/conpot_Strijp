FROM python:3.8 AS conpot-builder

RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy the app from the host folder (probably a cloned repo) to the container
RUN adduser --disabled-password --gecos "" conpot

COPY --chown=conpot:conpot . /opt/conpot/

# Install Conpot
USER conpot
ENV PATH=$PATH:/home/conpot/.local/bin
RUN pip3 install --user --no-cache-dir /opt/conpot


# Run container
FROM python:3.8-slim

RUN adduser --disabled-password --gecos "" conpot
WORKDIR /home/conpot

COPY --from=conpot-builder --chown=conpot:conpot /home/conpot/.local/ /home/conpot/.local/

# Create directories
RUN mkdir -p /var/log/conpot/ \
    && mkdir -p /data/tftp/ \
    && chown conpot:conpot /var/log/conpot \
    && chown conpot:conpot -R /data
RUN mkdir -p /etc/conpot/ && chown conpot:conpot /etc/conpot
ADD --chown=conpot:conpot conpot/templates/strijp_IEC104/ /etc/conpot/


USER conpot
WORKDIR /home/conpot
ENV USER=conpot
ENTRYPOINT ["/home/conpot/.local/bin/conpot"]
CMD ["--config", "/etc/conpot/conpot.cfg", "--template", "strijp_IEC104", "--logfile", "/var/log/conpot/conpot.log", "--temp_dir", "/tmp", "-f"]
