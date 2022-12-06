import React, { useState } from "react";
import "./App.css";

function App() {
  const my_api_url =
    process.env.REACT_APP_MY_API_URL || "http://localhost:3000";
  const [message, setMessage] = useState("");
  const postOrder = async () => {
    try {
      const res = await fetch(`${my_api_url}/order`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id: "123" }),
      });
      if (res.status === 200) {
        const response = await res.text();
        setMessage(response);
      } else {
        setMessage("Some error occured");
      }
    } catch (err) {
      console.log(err);
    }
  };
  const getOrder = async () => {
    try {
      const res = await fetch(`${my_api_url}/order?id=123`, {
        method: "GET",
      });
      if (res.status === 200) {
        const response = await res.text();
        setMessage(response);
      } else {
        setMessage("Some error occured");
      }
    } catch (err) {
      console.log(err);
    }
  };
  const deleteOrder = async () => {
    try {
      const res = await fetch(`${my_api_url}/delete`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id: "123" }),
      });
      if (res.status === 200) {
        const response = await res.text();
        setMessage(response);
      } else {
        setMessage("Some error occured");
      }
    } catch (err) {
      console.log(err);
    }
  };
  return (
    <div>
      <button onClick={postOrder}>POST</button>
      <button onClick={getOrder}>GET</button>
      <button onClick={deleteOrder}>DELETE</button>
      <div dangerouslySetInnerHTML={{ __html: message }}></div>
    </div>
  );
}

export default App;

