/**
 * Cloud Functions for Firebase
 * Updated with security fixes and improvements
 */
const { setGlobalOptions } = require("firebase-functions");
const { onRequest, onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

// Initialize with enhanced error handling
try {
  admin.initializeApp();

  // Emulator configuration with better checks
  if (process.env.FUNCTIONS_EMULATOR &&
      process.env.FUNCTIONS_EMULATOR.toLowerCase() === "true") {
    logger.info("Running in emulator mode", { service: "firestore" });

    admin.firestore().settings({
      host: "localhost:8080",
      ssl: false
    });
  }
} catch (err) {
  logger.error("Firebase initialization failed", { error: err });
  process.exit(1);
}

setGlobalOptions({
  maxInstances: 10,
  timeoutSeconds: 30,
  memory: "256MB"
});

// ====================== TYPE VALIDATION ====================== //
const validateAdminRequest = (data) => {
  if (!data.uid || typeof data.uid !== "string" || data.uid.length > 128) {
    throw new HttpsError("invalid-argument", "Invalid UID format");
  }

  if (!data.email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email)) {
    throw new HttpsError("invalid-argument", "Invalid email format");
  }
};

const validateProductRequest = (data) => {
  if (!data.productId || typeof data.productId !== "string" || data.productId.length > 128) {
    throw new HttpsError("invalid-argument", "Invalid product ID");
  }
};

// ====================== ADMIN FUNCTIONS ====================== //
exports.addAdminRole = onCall(async (data, context) => {
  try {
    // Enhanced security check
    if (!context.auth?.token?.admin) {
      throw new HttpsError("permission-denied", "Admin privileges required");
    }

    validateAdminRequest(data);

    await admin.auth().setCustomUserClaims(data.uid, { admin: true });

    // Log with more context
    logger.log("Admin role granted", {
      uid: data.uid,
      email: data.email,
      grantedBy: context.auth.uid
    });

    return {
      success: true,
      message: `${data.email} is now an admin`
    };
  } catch (err) {
    logger.error("Admin role assignment failed", {
      error: err.message,
      stack: err.stack,
      inputData: data
    });
    throw new HttpsError("internal", "Failed to grant admin privileges");
  }
});

exports.approveProduct = onCall(async (data, context) => {
  try {
    if (!context.auth?.token?.admin) {
      throw new HttpsError("permission-denied", "Admin privileges required");
    }

    validateProductRequest(data);

    const db = admin.firestore();
    const productRef = db.collection("products").doc(data.productId);
    const productDoc = await productRef.get();

    if (!productDoc.exists) {
      throw new HttpsError("not-found", "Product not found");
    }

    await productRef.update({
      approved: true,
      approvedBy: context.auth.uid,
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.log("Product approved", {
      productId: data.productId,
      approvedBy: context.auth.uid
    });

    return { success: true };
  } catch (err) {
    logger.error("Product approval failed", {
      error: err.message,
      productId: data.productId,
      adminId: context.auth?.uid
    });
    throw new HttpsError("internal", "Failed to approve product");
  }
});

// ====================== FIRESTORE TRIGGERS ====================== //
exports.onNewProduct = onDocumentCreated("products/{productId}", async (event) => {
  try {
    if (!event.data.exists) {
      logger.warn("Trigger fired for non-existent document");
      return;
    }

    const productData = event.data.data();
    const productId = event.params.productId;

    // Validate required fields
    if (!productData.name || !productData.userId) {
      logger.error("Invalid product data", { productId });
      return;
    }

    await admin.firestore().collection("admin_notifications").add({
      type: "new_product",
      productId: productId,
      productName: productData.name,
      submittedBy: productData.userId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      status: "pending"
    });

    logger.log("New product notification created", { productId });
  } catch (err) {
    logger.error("Product trigger failed", {
      error: err.message,
      productId: event.params.productId
    });
  }
});

// ====================== UTILITY ENDPOINTS ====================== //
exports.healthCheck = onRequest(async (req, res) => {
  try {
    await admin.firestore().collection("health").doc("check").get();
    res.status(200).json({
      status: "healthy",
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    logger.error("Health check failed", { error: err });
    res.status(500).json({ error: "Service unavailable" });
  }
});

const functions = require("firebase-functions");
const fetch = require("node-fetch");

const ALLOWED_HOSTNAMES = [
  "i.pinimg.com",
  "images.unsplash.com",
  "cdn.pixabay.com"
];

exports.imageProxy = functions.https.onRequest(async (req, res) => {
if (req.method === 'OPTIONS') {
    res.set('Access-Control-Allow-Origin', 'https://africulture.vercel.app');
    res.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type');
    return res.status(204).send('');
  }

  const { url } = req.query;
  if (!url) return res.status(400).send("Missing 'url' parameter.");

  try {
    const decodedUrl = decodeURIComponent(url);
    const targetUrl = new URL(decodedUrl);


    if (!ALLOWED_HOSTNAMES.includes(targetUrl.hostname)) {
      return res.status(403).send("This domain is not allowed.");
    }

    const response = await fetch(targetUrl.href);
    if (!response.ok) {
      return res.status(response.status).send("Image fetch failed.");
    }

    const contentType = response.headers.get("content-type");
    res.setHeader("Content-Type", contentType || "application/octet-stream");

    res.set('Access-Control-Allow-Origin', 'https://africulture.vercel.app');

    const buffer = await response.arrayBuffer();
    res.send(Buffer.from(buffer));
  } catch (err) {
    console.error("Proxy error:", err.message);
    res.status(500).send("Proxy failed: " + err.message);
  }
});
