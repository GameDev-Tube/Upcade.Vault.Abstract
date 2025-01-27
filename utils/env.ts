export const requiredEnv = (env_var: string): string => {
    // get
    const val: string = process.env[env_var] || "";

    // assert
    if (val === "") throw `Missing ${env_var} from environment`;

    // return
    return val;
};