# простой конфиг не Многоступенчатая сборка
FROM python:3.10.1-slim-bullseye

ENV POETRY_VERSION=1.3.2
ENV PYTHONUNBUFFERED 1
#WORKDIR /build
WORKDIR /code

# Create venv, add it to path and install requirements
#RUN python -m venv /venv
#ENV PATH="/venv/bin:$PATH"

#COPY requirements.txt .
#RUN pip install -r requirements.txt

RUN pip install "poetry==$POETRY_VERSION"

COPY poetry.lock pyproject.toml /code/

RUN poetry config virtualenvs.create false \
  && poetry install $(test "$YOUR_ENV" == production && echo "--no-dev") --no-interaction --no-ansi

# Install uvicorn server
RUN pip install uvicorn[standard]

# Copy the rest of app
#COPY app app
#COPY alembic alembic
#COPY alembic.ini .
#COPY pyproject.toml .
#COPY init.sh .

COPY . /code

# Create new user to run app process as unprivilaged user
#RUN addgroup --gid 1001 --system uvicorn && \
#    adduser --gid 1001 --shell /bin/false --disabled-password --uid 1001 uvicorn

# Run init.sh script then start uvicorn
#RUN chown -R uvicorn:uvicorn /build
#CMD bash init.sh && \
#    runuser -u uvicorn -- /venv/bin/uvicorn app.main:app --app-dir /build --host 0.0.0.0 --port 8000 --workers 2 --loop uvloop

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

EXPOSE 8000