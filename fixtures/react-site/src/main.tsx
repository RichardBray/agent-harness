import { createRoot } from "react-dom/client";
import { App } from "./App.js";

const el = document.getElementById("root");
if (el !== null) createRoot(el).render(<App />);
