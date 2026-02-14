import { MongoClient } from 'mongodb'

const uri = process.env.MONGODB_URI || ''
const dbName = process.env.MONGODB_DB || 'mehad'

if (!uri) {
  console.warn('MONGODB_URI not set — API routes will return an error until configured')
}

let cached = global._mongo
if (!cached) {
  cached = global._mongo = { conn: null, promise: null }
}

export async function connectToDatabase() {
  if (!uri) throw new Error('MONGODB_URI not set in environment')
  if (cached.conn) return cached.conn
  if (!cached.promise) {
    const client = new MongoClient(uri)
    cached.promise = client.connect().then(async (client) => {
      return { client, db: client.db(dbName) }
    })
  }
  cached.conn = await cached.promise
  return cached.conn
}

export default connectToDatabase
