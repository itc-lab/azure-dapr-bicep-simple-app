const express = require("express");
const path = require("path");
const axios = require("axios");

const app = express();
app.use(express.json());

const port = 3000;
const pythonService = process.env.PYTHON_SERVICE_NAME || "python-app";
const daprPort = process.env.DAPR_HTTP_PORT || 3500;

//use dapr http proxy (header) to call orders service with normal /order route URL in axios.get call
const daprSidecar = `http://localhost:${daprPort}`;

app.get("/order", async (req, res) => {
  try {
    var data = await axios.get(`${daprSidecar}/order?id=${req.query.id}`, {
      headers: { "dapr-app-id": `${pythonService}` }, //sets app name for service discovery
    });
    res.setHeader("Content-Type", "application/json");
    res.send(
      `<p>Order GET successfully!</p><br/><code>${JSON.stringify(
        data.data
      )}</code>`
    );
  } catch (err) {
    res.send(
      `<p>Error getting order<br/>Order microservice or dapr may not be running.<br/></p><br/><code>${err}</code>`
    );
  }
});

app.post("/order", async (req, res) => {
  try {
    var order = req.body;
    order["location"] = "Seattle";
    order["priority"] = "Standard";
    console.log(
      "Service invoke POST to: " +
        `${daprSidecar}/order?id=${req.query.id}` +
        ", with data: " +
        JSON.stringify(order)
    );
    var data = await axios.post(
      `${daprSidecar}/order?id=${req.query.id}`,
      order,
      {
        headers: { "dapr-app-id": `${pythonService}` }, //sets app name for service discovery
      }
    );

    res.send(
      `<p>Order created!</p><br/><code>${JSON.stringify(data.data)}</code>`
    );
  } catch (err) {
    res.send(
      `<p>Error creating order<br/>Order microservice or dapr may not be running.<br/></p><br/><code>${err}</code>`
    );
  }
});

app.post("/delete", async (req, res) => {
  try {
    var data = await axios.delete(`${daprSidecar}/order?id=${req.body.id}`, {
      headers: { "dapr-app-id": `${pythonService}` },
    });

    res.setHeader("Content-Type", "application/json");
    res.send(`${JSON.stringify(data.data)}`);
  } catch (err) {
    res.send(
      `<p>Error deleting order<br/>Order microservice or dapr may not be running.<br/></p><br/><code>${err}</code>`
    );
  }
});

// Serve static files
app.use(express.static(path.join(__dirname, "client/build")));

// For default home request route to React client
app.get("/", async function (_req, res) {
  try {
    return await res.sendFile(
      path.join(__dirname, "client/build", "index.html")
    );
  } catch (err) {
    console.log(err);
  }
});

app.listen(process.env.PORT || port, () =>
  console.log(`Listening on port ${port}!`)
);
