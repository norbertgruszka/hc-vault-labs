FROM python:3.10.0
RUN pip install hvac
COPY ./unseal.py /run/
WORKDIR /run/
CMD python3 ./unseal.py