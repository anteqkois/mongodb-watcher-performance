import 'dotenv/config';
import {ChangeStream, Collection} from 'mongodb';
import {MongoDbClient} from './client';

let insertInterval: NodeJS.Timeout;
let testCollection: Collection;
let testCollectionStream: ChangeStream;

const startInsertInterval = () => {
  insertInterval = setInterval(async () => {
    await testCollection.insertOne({
      test: 'test',
    });
  }, 1000);
};
const main = async () => {
  const mongoClient = new MongoDbClient({
    connectString: process.env.MONGO_URL!,
    id: 'main',
  });
  testCollection = mongoClient.client
    .db(process.env.MONGO_DB!)
    .collection('test');

  startInsertInterval();

  console.log(await testCollection.countDocuments());

  testCollectionStream = testCollection.watch();
  testCollectionStream.on('change', change => {
    console.log('Change detected:', change);
  });
};

main()
  .then()
  .catch(err => {
    console.log(err);
    process.exit(1);
  });

process.on('SIGINT', async () => {
  console.log('Shutting down...');
  clearInterval(insertInterval);
  testCollectionStream.close();
  process.exit(0);
});
