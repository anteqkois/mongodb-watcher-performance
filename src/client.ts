import { MongoClient } from 'mongodb';

export class MongoDbClient {
  public url: string;
  public client: MongoClient;

  constructor({connectString, id}: MongoDbClientSettings) {
    if (!connectString) {
      throw new Error(`missing connectString ${id}`);
    }
    this.url = connectString;

    this.client = new MongoClient(this.url, {
      // compressors: 'zstd',
      socketTimeoutMS: 5_000,
      timeoutMS: 5_000,
    });

    this.client.on('error', err => {
      console.info(`#${id} error`, err);
    });

    this.client
      .connect()
      .then(() => {
        console.info(`#${id} connected to database`);
      })
      .catch(err => {
        console.error(`#${id} can not connect to database`, err);
      });
  }
}

export interface MongoDbClientSettings {
  connectString: string;
  id: string;
}
