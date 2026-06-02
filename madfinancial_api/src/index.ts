import { Api } from "./api";

const main = async () => {
    const app = new Api();
    return await app.listen();
};

main().then(response => console.log(response));
